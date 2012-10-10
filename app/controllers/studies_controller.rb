class StudiesController < ApplicationController
  before_filter :set_protocol_type
  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @study = Study.new
    @study.requester_id = @current_user.id
    @study.build_research_types_info
    @study.build_human_subjects_info
    @study.build_vertebrate_animals_info
    @study.build_investigational_products_info
    @study.build_ip_patents_info
    @study.setup_study_types
    @study.setup_impact_areas
    @study.setup_affiliations
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    @study = Study.new params[:study]

    if @study.valid?
      @study.save
      session[:saved_study_id] = @study.id
      flash[:notice] = "New study created"
    else
      @study.setup_study_types
      @study.setup_impact_areas
      @study.setup_affiliations
    end
  end

  def edit
    @service_request = ServiceRequest.find session[:service_request_id]
    @study = @current_user.studies.find params[:id]
    @study.setup_study_types
    @study.setup_impact_areas
    @study.setup_affiliations
  end

  def update
    @service_request = ServiceRequest.find session[:service_request_id]
    @study = @current_user.studies.find params[:id]

    puts "#"*50
    puts params[:study].inspect
    puts "#"*50

    if @study.update_attributes params[:study]
      session[:saved_study_id] = @study.id
      flash[:notice] = "Study updated"
    end
      
    @study.setup_study_types
    @study.setup_impact_areas
    @study.setup_affiliations
  end

  def destroy

  end

  def set_protocol_type
    session[:protocol_type] = 'study'
  end
end
