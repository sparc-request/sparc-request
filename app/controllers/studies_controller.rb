class StudiesController < ApplicationController
  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @study = Study.new
    @study.build_research_types_info
    @study.build_human_subjects_info
    @study.build_vertebrate_animals_info
    @study.build_investigational_products_info
    @study.build_ip_patents_info
    @study.setup_study_types

    #@study.setup_study_types
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    @study = Study.new params[:study]

    if @study.valid?
      @study.save
    else
      @study.setup_study_types
    end
  end

  def edit
    #@study.setup_study_types!
  end

  def update

  end

  def destroy

  end
end
