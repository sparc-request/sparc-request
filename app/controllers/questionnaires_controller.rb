class QuestionnairesController < ApplicationController
  before_action :find_service
  layout 'additional_details'

  def index
    @questionnaires = @service.questionnaires
  end

  def new
    @questionnaire = Questionnaire.new
    @questionnaire.items.build
  end

  def edit
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.items.build
  end

  def create
    @questionnaire = Questionnaire.new(questionnaire_params)
    @questionnaire.service = Service.find(params[:service_id])
    if @questionnaire.save
      redirect_to service_questionnaires_path(@service)
    else
      render :new
    end
  end

  private

  def find_service
    @service = Service.find(params[:service_id])
  end

  def questionnaire_params
    params.require(:questionnaire).permit!
  end
end
