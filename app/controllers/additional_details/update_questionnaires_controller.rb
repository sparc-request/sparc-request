class AdditionalDetails::UpdateQuestionnairesController < ApplicationController

  def update
    @service = Service.find(params[:service_id])
    @questionnaire = Questionnaire.find(params[:id])
    update_questionnaire(@questionnaire)
    if @questionnaire.save
      redirect_to service_additional_details_questionnaires_path(@service)
      flash[:notice] = 'Questionnaire updated'
    else
      redirect_to service_additional_details_questionnaires_path(@service)
      flash[:error] = 'Something went wrong'
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
