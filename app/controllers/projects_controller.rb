class ProjectsController < ApplicationController
  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @project = Project.new
    @project.build_research_types_info
    @project.build_human_subjects_info
    @project.build_vertebrate_animals_info
    @project.build_investigational_products_info
    @project.build_ip_patents_info
    @project.build_study_types
    @project.build_impact_areas
    @project.build_affiliations  
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    puts "#"*50
    puts params.inspect
    puts "#"*50
    @project = Project.new params[:project]
    puts "#"*50
    puts @project.research_types_info
    puts "#"*50

    if @project.valid?
      @project.save
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end
end
