# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Surveyor::ResponsesController < Surveyor::BaseController
  respond_to :html, :js, :json, :xlsx

  before_action :authenticate_identity!
  before_action :find_response, only: [:show, :edit, :update]

  def set_highlighted_link
    @highlighted_link ||= 'sparc_forms'
  end

  def index
    @filterrific  =
      initialize_filterrific(Response, params[:filterrific] && sanitize_dates(filterrific_params, [:start_date, :end_date]),
        default_filter_params: {
          include_incomplete: 'false',
          of_type: 'SystemSurvey'
        },
        select_options: {
          of_type: [['Survey', 'SystemSurvey'], ['Form', 'Form']]
        }
      ) || return

    @type = @filterrific.of_type.constantize.yaml_klass

    respond_to do |format|
      format.html
      format.js
      format.json {
        load_responses
      }
      format.xlsx {
        load_responses
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@type} Responses.xlsx\""
      }
    end
  end

  def show
    @survey = @response.survey

    respond_to do |format|
      format.html
      format.js
      format.xlsx
    end
  end

  def new
    @survey = params[:type].constantize.find(params[:survey_id])
    @response = @survey.responses.new
    @response.question_responses.build
    @respondable = params[:respondable_type].constantize.find(params[:respondable_id])

    respond_to do |format|
      format.html {
        existing_response = Response.where(survey: @survey, identity: current_user, respondable: @respondable).first
        redirect_to surveyor_response_complete_path(existing_response) if existing_response
      }
      format.js
    end
  end

  def edit
    @survey = @response.survey

    respond_to do |format|
      format.js
      format.html { # Only used to take System Surveys via Service Survey emails
        redirect_to surveyor_response_complete_path(@response) if @response.completed?
        @response.question_responses.build
      }
    end
  end

  def create
    @response           = Response.new(response_params)
    @protocol           = @response.respondable.try(:protocol)
    @protocol_role      = @protocol.project_roles.find_by(identity_id: current_user.id) if @protocol
    @permission_to_edit = @protocol_role.nil? ? false : @protocol_role.can_edit? if @protocol

    if @response.save
      SurveyNotification.system_satisfaction_survey(@response).deliver_now if @response.survey.access_code == 'system-satisfaction-survey' && Rails.application.routes.recognize_path(request.referrer)[:action] == 'review'
      flash[:success] = t(:surveyor)[:responses][:completed]
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    if @response.update_attributes(response_params)
      flash[:success] = t(:surveyor)[:responses][:completed]
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @response           = Response.find(params[:id])
    @protocol           = @response.respondable.try(:protocol)
    @protocol_role      = @protocol.project_roles.find_by(identity_id: current_user.id) if @protocol
    @permission_to_edit = @protocol_role.nil? ? false : @protocol_role.can_edit? if @protocol

    @response.destroy

    respond_to do |format|
      format.js
    end
  end

  def complete
  end

  def resend_survey
    @response = Response.find(params[:response_id])
    if @response.survey.access_code == 'system-satisfaction-survey'
      SurveyNotification.system_satisfaction_survey(@response).deliver
      @response.update_attribute(:updated_at, Time.now)
    else
      SurveyNotification.service_survey([@response.survey], @response.identity, @response.try(:respondable)).deliver
    end
    flash[:success] = t(:surveyor)[:responses][:resent]
  end

  private

  def find_response
    @response = Response.find(params[:id])
  end

  def filterrific_params
    params.require(:filterrific).permit(
      :reset_filterrific,
      :of_type,
      :start_date,
      :end_date,
      :include_incomplete,
      with_state: [],
      with_survey: []
    )
  end

  def response_params
    params.require(:response).permit!
  end

  def load_responses
    @responses =
      if @type == Survey.name
        @filterrific.find.eager_load(:survey, :question_responses, :identity)
      else
        existing_responses = @filterrific.find.eager_load(:survey, :question_responses, :identity).
          where(survey: Form.for(current_user))

        if @filterrific.include_incomplete == 'false'
          existing_responses
        else
          incomplete_responses = get_incomplete_form_responses
          existing_responses + incomplete_responses
        end
      end
    preload_responses
  end

  def preload_responses
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(@responses.select { |r| r.respondable_type == SubServiceRequest.name }, { respondable: { protocol: { primary_pi_role: :identity } } })
    preloader.preload(@responses.select { |r| r.respondable_type == ServiceRequest.name }, { respondable: { protocol: { primary_pi_role: :identity } } })
  end

  def get_incomplete_form_responses
    @filterrific.with_state.reject!(&:blank?) if @filterrific.with_state
    @filterrific.with_survey.reject!(&:blank?) if @filterrific.with_survey

    responses = []
    Protocol.eager_load(sub_service_requests: [:responses, :service_forms, :organization_forms]).distinct.each do |p|
      p.sub_service_requests.each do |ssr|
        ssr.forms_to_complete.select do |f|
          # Apply the State, Survey/Form, and Start/End Date filters manually
          (@filterrific.with_state.try(&:empty?) || (@filterrific.with_state.try(&:any?) && @filterrific.with_state.include?(f.active ? 1 : 0))) &&
          (@filterrific.with_survey.try(&:empty?) || (@filterrific.with_survey.try(&:any?) && @filterrific.with_survey.include?(f.id)))
        end.each do |f|
          responses << Response.new(survey: f,respondable: ssr)
        end
      end
    end

    responses
  end

end
