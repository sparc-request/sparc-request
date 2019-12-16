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

class Surveyor::SurveysController < Surveyor::BaseController
  respond_to :html, :js, :json

  before_action :authenticate_identity!
  before_action :authorize_survey_builder_access

  def index
    respond_to do |format|
      format.html
      format.json {
        @surveys = 
          if params[:type] == "SystemSurvey"
            SystemSurvey.all
          elsif params[:type] == "Form"
            Form.for(current_user)
          else
            Survey.none
          end
      }
    end
  end

  def new
    @survey = Survey.new(type: params[:type])
  end

  def create
    @survey = build_survey

    if @survey.save
      redirect_to edit_surveyor_survey_path(@survey, type: params[:type]), format: :js
    else
      @errors = @survey.errors
    end
  end

  def edit
    @survey = Survey.eager_load(sections: { questions: :options }).find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @survey = Survey.find(params[:id])
    @type   = @survey.class.name.snakecase.dasherize.downcase
    
    @survey.destroy

    respond_to do |format|
      format.js
    end
  end

  def preview
    @survey = Survey.find(params[:survey_id])
    @response = @survey.responses.new()
    @response.question_responses.build

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_dependents_list
    @survey     = Survey.find(params[:survey_id])
    @questions  = @survey.questions.eager_load(section: { survey: { questions: :options } })

    respond_to do |format|
      format.js
    end
  end

  def copy
    @survey = Survey.find(params[:survey_id]).clone
    @survey.save
  end

  def search_surveyables
    term            = params[:term].strip
    org_ids         =
      if current_user.is_site_admin?
        Organization.all.ids
      else
        Organization.authorized_for_super_user(current_user.id).or(
          Organization.authorized_for_service_provider(current_user.id)).or(
          Organization.authorized_for_catalog_manager(current_user.id)).ids
      end
    service_ids     = Service.where(organization_id: org_ids).ids
    
    org_results     = Organization.where("(name LIKE ? OR abbreviation LIKE ?) AND is_available = 1 AND process_ssrs = 1 AND id IN (?)", "%#{term}%", "%#{term}%", org_ids)
    service_results = Service.where("(name LIKE ? OR abbreviation LIKE ? OR cpt_code LIKE ?) AND is_available = 1 AND id IN (?)", "%#{term}%", "%#{term}%", "%#{term}%", service_ids).reject{ |s| (s.current_pricing_map rescue false) == false}
    results         = org_results + service_results
    
    results.map!{ |r|
      {
        breadcrumb:     helpers.breadcrumb_text(r),
        klass:          r.is_a?(Service) ? 'Service' : 'Organization',
        org_color:     "text-#{r.class.name.downcase}",
        label:          r.name,
        value:          r.id,
        cpt_code:       r.try(:cpt_code),
        term:           term
      }
    }

    render json: results.to_json
  end

  private

  def build_survey
    klass = params[:type].constantize

    if existing = klass.where(survey_params).last
      @survey = existing.clone
    else
      @survey = klass.new(
        title: t('surveyor.surveys.new_form.header', klass: "#{klass.model_name.human}"),
        access_code: survey_params[:access_code],
        version: 1,
        active: false,
        surveyable: klass == Form ? current_user : nil
      )
    end
  end

  def survey_params
    params.require(params[:type].underscore).permit(
      :access_code
    )
  end
end
