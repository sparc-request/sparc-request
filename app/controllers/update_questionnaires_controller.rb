class UpdateQuestionnairesController < ApplicationController

  def update
    @service = Service.find(params[:service_id])
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.update_attribute(:active, true)
    if @questionnaire.save
      redirect_to service_questionnaires_path(@service)
    else
      redirect_to :back
    end
  end
end
