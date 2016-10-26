class AdditionalDetails::UpdateQuestionnairesController < ApplicationController

  def update
    @service = Service.find(params[:service_id])
    @questionnaires = @service.questionnaires
    @questionnaire = Questionnaire.find(params[:id])
    update_questionnaire(@questionnaire)
    respond_to do |format|
      if @questionnaire.save
        format.js
      else
        format.js
      end
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
