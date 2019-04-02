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

class Surveyor::SurveyUpdaterController < Surveyor::BaseController
  respond_to :js

  before_action :authenticate_identity!
  before_action :authorize_survey_builder_access
  
  def update
    @klass  = params[:klass]
    @object = @klass.capitalize.constantize.find(params[:id])
    @field  = survey_updater_params.keys[0]
    @params = survey_updater_params

    if @field == 'access_code'
      @params['version'] = (@object.class.where.not(id: @object.id).where(access_code: @params[@field]).try(:maximum, :version) || 0) + 1
    end

    @object.assign_attributes(@params)
    @object.valid?

    if @object.errors.keys.include?(@field.to_sym)
      @errors = @object.errors
    else
      @object.save(validate: false)
    end
  end

  private

  def survey_updater_params
    case @klass
    when 'survey'
      params.require(:survey).permit(
        :title,
        :description,
        :access_code,
        :version,
        :active,
        :surveyable_id,
        :surveyable_type
      )
    when 'section'
      params.require(:section).permit(
        :title,
        :description
      )
    when 'question'
      params.require(:question).permit(
        :content,
        :description,
        :question_type,
        :required,
        :is_dependent,
        :depender_id
      )
    when 'option'
      params.require(:option).permit(
        :content
      )
    end
  end
end
