class AdditionalDetails::SubmissionsController < ApplicationController
  layout 'additional_details'
  include AdditionalDetails::StatesHelper

  def index
    @service = Service.find(params[:service_id])
    @submissions = @service.submissions
  end

  def show
    @submission = Submission.find(params[:id])
    @questionnaire_responses = @submission.questionnaire_responses
    @questionnaire = Questionnaire.find(@submission.questionnaire_id)
    @items = @questionnaire.items
    respond_to do |format|
      format.js
    end
  end

  def new
    @service = Service.find(params[:service_id])
    @questionnaire = @service.questionnaires.active.first
    @submission = Submission.new
    @submission.questionnaire_responses.build
    respond_to do |format|
      format.js
    end
  end

  def edit
    @service = Service.find(params[:service_id])
    @submission = Submission.find(params[:id])
    @questionnaire = @service.questionnaires.active.first
    respond_to do |format|
      format.js
    end
  end

  def create
    @service = Service.find(params[:service_id])
    @questionnaire = @service.questionnaires.active.first
    @submission = Submission.new(submission_params)
    @protocol = Protocol.find(submission_params[:protocol_id])
    @submissions = @protocol.submissions
    @line_item = LineItem.find(submission_params[:line_item_id])
    @service_request = @line_item.service_request
    @permission_to_edit = @protocol.project_roles.where(identity: current_user, project_rights: ['approve', 'request']).any?
    
    respond_to do |format|
      if @submission.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @service = Service.find(params[:service_id])
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
    @service = Service.find(params[:service_id])
    @submission = Submission.find(params[:id])
    if params[:protocol_id]
      @protocol = Protocol.find(params[:protocol_id])
      @submissions = @protocol.submissions
      @permission_to_edit = @protocol.project_roles.where(identity: current_user, project_rights: ['approve', 'request']).any?
    end
    if params[:line_item_id]
      @line_item = LineItem.find(params[:line_item_id])
      @service_request = ServiceRequest.find(@line_item.service_request_id)
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
