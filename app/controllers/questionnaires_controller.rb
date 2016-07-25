class QuestionnairesController < ApplicationController
  layout 'additional_details'

  def new
    @service = Service.find(params[:service_id])
    @questionnaire = Questionnaire.new
    @questionnaire.items.build
  end

  def create
    @questionnaire = Questionnaire.new(questionnaire_params)
    @questionnaire.service = Service.find(params[:service_id])
    if @questionnaire.save
      redirect_to :back
    else
      render :new
    end
  end

  private

  def questionnaire_params
    params.require(:questionnaire).permit!
  end
end
