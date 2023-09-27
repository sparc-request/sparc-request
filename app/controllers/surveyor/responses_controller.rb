# Copyright © 2011-2022 MUSC Foundation for Research Development
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
    @admin_org_ids = (current_user.is_site_admin? ? Organization.all : current_user.authorized_admin_organizations).pluck(:id)

    @filterrific  =
      initialize_filterrific(Response, params[:filterrific] && filterrific_params,
        default_filter_params: {
          include_incomplete: 'false',
          of_type: 'SystemSurvey'
        },
        select_options: {
          of_type: [['Survey', 'SystemSurvey'], ['Form', 'Form']]
        }
      ) || return

    @type = @filterrific.of_type.constantize.model_name.human

    respond_to do |format|
      format.html
      format.js {
        @url = request.base_url + request.path + '?' + params.slice(:filterrific).permit!.to_query
      }
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

    respond_to :js
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
      SurveyNotification.system_satisfaction_survey(@response).deliver_now if @response.survey.access_code == 'system-satisfaction-survey' && helpers.request_referrer_action == 'review'
      flash[:success] = t(:surveyor)[:responses][:completed]
    else
      @errors = @response.errors
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    if @response.update_attributes(response_params)
      flash[:success] = t(:surveyor)[:responses][:completed]
    else
      @errors = @response.errors
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
    @response = Response.find(params[:response_id])
    if @response.respondable_id && @response.respondable.organization.survey_completion_alerts
      ### Per discussions, if Survey Alert is checked for the organization, email alerts go out
      ### to those relevant super users who want to receive emails.
      @response.respondable.organization.all_super_users.each do |su|
        next if su.hold_emails
        SurveyNotification.service_survey_completed(@response, @response.respondable, su).deliver_later
      end
    end
  end

  def resend_survey
    @response = Response.find(params[:response_id])
    ## resend button is disabled for surveys that are not tied to any organization

    SurveyNotification.service_survey([@response.survey], [@response.identity], @response.try(:respondable)).deliver
    flash[:success] = t(:surveyor)[:responses][:resent]
  end

  private

  def find_response
    @response = Response.find(params[:id])
  end

  def filterrific_params
    params[:filterrific][:start_date] = sanitize_date params[:filterrific][:start_date]
    params[:filterrific][:end_date]   = sanitize_date params[:filterrific][:end_date]

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
        ## https://www.pivotaltracker.com/n/projects/1918597/stories/167076358
        if current_user.is_site_admin?
          @filterrific.find.eager_load(:survey, :question_responses, :identity)
        else
          @filterrific.find.eager_load(:survey, :question_responses, :identity).
            where(survey: SystemSurvey.for(current_user), respondable_id: SubServiceRequest.where(organization_id: @admin_org_ids))
        end
      else
        existing_responses = @filterrific.find.eager_load(:survey, :question_responses, :identity).
          where(survey: Form.for_admin_users(current_user))

        if @filterrific.include_incomplete == 'false'
          existing_responses
        else
          incomplete_responses = get_incomplete_form_responses
          incomplete_responses + existing_responses
        end
      end
    preload_responses
  end

  def preload_responses
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(@responses.select { |r| r.respondable_type == SubServiceRequest.name }, [:question_responses, :identity, respondable: { protocol: :primary_pi } ])
    preloader.preload(@responses.select { |r| r.respondable_type == ServiceRequest.name }, [:question_responses, :identity, respondable: { protocol: :primary_pi } ])
  end

  def get_incomplete_form_responses
    @filterrific.with_state.reject!(&:blank?) if @filterrific.with_state
    @filterrific.with_survey.reject!(&:blank?) if @filterrific.with_survey

    state_selected  = @filterrific.with_state.try(&:any?)
    survey_selected = @filterrific.with_survey.try(&:any?)

    responses = []
    ssrs      = SubServiceRequest.eager_load(:responses, :service_forms, :organization_forms).where(organization_id: @admin_org_ids) # It should only shows those admin have access to
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(ssrs, service_forms: :surveyable)
    preloader.preload(ssrs, organization_forms: :surveyable)

    ssrs.each do |ssr|
      ssr.forms_to_complete.values.flatten.select do |f|
        # Apply the State, Survey/Form, and Start/End Date filters manually
        (!state_selected || (state_selected && @filterrific.with_state.include?(f.active ? 1 : 0))) &&
        (!survey_selected || (@filterrific.with_survey.try(&:any?) && @filterrific.with_survey.include?(f.id)))
      end.each do |f|
        responses << Response.new(survey: f,respondable: ssr)
      end
    end

    responses
  end

end
