class StudiesController < ApplicationController
  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @study = Study.new
    @study.build_research_types_info
    @study.build_human_subjects_info
    @study.build_vertebrate_animals_info
    @study.build_investigational_products_info
    @study.build_ip_patents_info
    @study.build_study_types
    @study.build_impact_areas
    @study.build_affiliations  
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    puts "#"*50
    puts params.inspect
    puts "#"*50
    @study = Study.new params[:study]
    puts "#"*50
    puts @study.research_types_info
    puts "#"*50

    if @study.valid?
      @study.save
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end
end
