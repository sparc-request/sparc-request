# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class AdditionalDetails::SubmissionsController < ApplicationController
  before_action :authenticate_identity!
  layout 'additional_details'
  include AdditionalDetails::StatesHelper

  def index
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @questionable = @questionnaire.questionable
    @submissions = @questionnaire.submissions
  end

  def show
    @submission = Submission.find(params[:id])
    @questionnaire_responses = @submission.questionnaire_responses
    @questionnaire = @submission.questionnaire
    @items = @questionnaire.items
    respond_to do |format|
      format.js
    end
  end

  def new
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
    @submission = Submission.new
    @submission.questionnaire_responses.build
    respond_to do |format|
      format.js
    end
  end

  def edit
    @submission = Submission.find(params[:id])
    @questionnaire = @submission.questionnaire
    respond_to do |format|
      format.js
    end
  end

  def create
    @submission = Submission.new(submission_params)
    @questionnaire = @submission.questionnaire
    @protocol = Protocol.find(submission_params[:protocol_id])
    @submissions = @protocol.submissions
    @sub_service_request = @submission.sub_service_request
    @service_request = @sub_service_request.service_request
    @permission_to_edit = current_user.can_edit_protocol?(@protocol)
    @user = current_user
    
    respond_to do |format|
      if @submission.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @submission = Submission.find(params[:id])
    @protocol = @submission.protocol
    @submissions = @protocol.submissions
    if params[:sr_id]
      @service_request = ServiceRequest.find(params[:sr_id])
    end
    @submission.update_attributes(submission_params)
    respond_to do |format|
      if @submission.save
        @submission.touch(:updated_at)
        format.js
      else
        format.js
      end
    end
  end

  def destroy
    @submission = Submission.find(params[:id])
    @user = current_user
    if params[:protocol_id]
      @protocol = Protocol.find(params[:protocol_id])
      @submissions = @protocol.submissions
      @permission_to_edit = current_user.can_edit_protocol?(@protocol)
    else
      @submissions = @submission.questionnaire.submissions
    end
    if params[:ssr_id]
      @sub_service_request = SubServiceRequest.find(params[:ssr_id])
      @service_request = ServiceRequest.find(@sub_service_request.service_request_id)
    end
    respond_to do |format|
      if @submission.destroy
        format.js
      else
        format.js
      end
    end
  end

  private

  def submission_params
    params.require(:submission).permit!
  end
end
