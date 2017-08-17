# Copyright © 2011-2016 MUSC Foundation for Research Development
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

class Surveyor::ResponsesController < ApplicationController
  respond_to :html, :js, :json

  before_action :authenticate_identity!
  before_action :find_survey, only: [:new]

  def show
    @response = Response.find(params[:id])
    @survey   = @response.survey

    respond_to do |format|
      format.html
    end
  end

  def new
    @response = @survey.responses.new
    @response.question_responses.build

    respond_to do |format|
      format.html {
        @review = 'false'
        @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      }
      format.js {
        @review = 'true'
        @sub_service_request = nil
      }
    end
  end

  def create
    @response = Response.new(response_params)
    @review   = params[:review] == 'true'

    if @response.save && @response.question_responses.none? { |qr| qr.errors.any? }
      # Delete responses to questions that didn't show anyways to avoid confusion in the data
      @response.question_responses.where(required: true, content: [nil, '']).destroy_all
      SurveyNotification.system_satisfaction_survey(@response).deliver_now if @response.survey.access_code == 'system-satisfaction-survey' && @review
      
      flash[:success] = t(:surveyor)[:responses][:create]
    else
      @response.destroy
      
      @errors = true
    end
  end

  private

  def find_survey
    surveys = Survey.where(access_code: params[:access_code], active: true).order('version DESC')

    if params[:version]
      @survey = surveys.where(version: params[:version]).first
    else
      @survey = surveys.first
    end
  end

  def response_params
    params.require(:response).permit!
  end
end
