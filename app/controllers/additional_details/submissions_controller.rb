class AdditionalDetails::SubmissionsController < ApplicationController
  before_action :authenticate_identity!
  layout 'additional_details'
  include AdditionalDetails::StatesHelper

  def index
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
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
    @protocol = @submission.protocol
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
    @protocol = Protocol.find(@submission.protocol_id)
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
      @submissions = @submission.protocol.submissions
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
