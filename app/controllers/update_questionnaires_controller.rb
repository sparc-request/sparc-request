class UpdateQuestionnairesController < ApplicationController

  def update
    @service = Service.find(params[:service_id])
    @questionnaire = Questionnaire.find(params[:id])
    update_questionnaire(@questionnaire)
    if @questionnaire.save
      redirect_to service_questionnaires_path(@service)
    else
      redirect_to :back
    end
  end

  private

  def update_questionnaire(questionnaire)
    if questionnaire.active?
      questionnaire.update_attribute(:active, false)
    else
      questionnaire.update_attribute(:active, true)
    end
  end
end
