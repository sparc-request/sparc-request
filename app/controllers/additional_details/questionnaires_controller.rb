class AdditionalDetails::QuestionnairesController < ApplicationController
  before_action :find_service
  before_action :find_questionnaire, only: [:edit, :update, :destroy]
  layout 'additional_details'

  def index
    @questionnaires = @service.questionnaires
  end

  def new
    @questionnaire = Questionnaire.new
    @questionnaire.items.build
  end

  def edit
  end

  def create
    @questionnaire = Questionnaire.new(questionnaire_params)
    @questionnaire.service = Service.find(params[:service_id])
    if @questionnaire.save
      redirect_to service_additional_details_questionnaires_path(@service)
    else
      render :new
    end
  end

  def update
    @questionnaire.update_attributes(questionnaire_params)
    if @questionnaire.save
      redirect_to service_additional_details_questionnaires_path(@service)
    else
      render :edit
    end
  end

  def destroy
    @questionnaire.destroy
    redirect_to service_additional_details_questionnaires_path(@service)
  end

  private

  def find_questionnaire
    @questionnaire = Questionnaire.find(params[:id])
  end

  def find_service
    @service = Service.find(params[:service_id])
  end

  def questionnaire_params
    params.require(:questionnaire).permit!
  end
end
