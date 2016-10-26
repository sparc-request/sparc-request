class AdditionalDetails::PreviewsController < ApplicationController

  def create
    @service = Service.find(params[:service_id])
    @questionnaire = Questionnaire.new(questionnaire_params)
    @submission = Submission.new
    @submission.questionnaire_responses.build
    respond_to do |format|
      format.js
    end
  end

  private

  def questionnaire_params
    params.require(:questionnaire).permit!
  end
end
