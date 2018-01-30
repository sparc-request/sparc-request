# Copyright © 2011-2017 MUSC Foundation for Research Development
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
  respond_to :html, :js, :json

  before_action :authenticate_identity!
  before_action :find_survey, only: [:new]
  before_action :find_response, only: [:show, :edit, :update]

  def show
    @survey = @response.survey

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @response = @survey.responses.new
    @response.question_responses.build
    @respondable = params[:respondable_type].constantize.find(params[:respondable_id])

    respond_to do |format|
      format.html {
        existing_response = Response.where(survey: @survey, respondable_id: params[:respondable_id], respondable_type: params[:respondable_type]).first
        redirect_to surveyor_response_complete_path(existing_response) if existing_response
      }
      format.js
    end
  end

  def edit
    @survey = @response.survey

    respond_to do |format|
      format.js
    end
  end

  def create
    @response = Response.new(response_params)

    if @response.save
      SurveyNotification.system_satisfaction_survey(@response).deliver_now if @response.survey.access_code == 'system-satisfaction-survey' && Rails.application.routes.recognize_path(request.referrer)[:action] == 'review'
      flash[:success] = t(:surveyor)[:responses][:create]
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    if @response.update_attributes(response_params)
      flash[:success] = t(:surveyor)[:responses][:update]
    end
  end

  def destroy
    (@response = Response.find(params[:id])).destroy
  end

  def complete
  end

  private

  def find_survey
    @survey = params[:type].constantize.find(params[:survey_id])
  end

  def find_response
    @response = Response.find(params[:id])
  end

  def response_params
    params.require(:response).permit!
  end
end
