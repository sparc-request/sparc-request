class ProjectsController < ApplicationController
  before_filter :set_protocol_type
  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @project = Project.new
    @project.requester_id = @current_user.id
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    @project = Project.new params[:project]

    if @project.valid?
      @project.save
      @service_request.protocol = @project
      @service_request.save
      flash[:notice] = "New project created"
    end
  end

  def edit
    @service_request = ServiceRequest.find session[:service_request_id]
    @project = @current_user.projects.find params[:id]
  end

  def update
    @service_request = ServiceRequest.find session[:service_request_id]
    @project = @current_user.projects.find params[:id]

    if @project.update_attributes params[:project]
      flash[:notice] = "Project updated"
    end
  end

  def destroy

  end

  def set_protocol_type
    session[:protocol_type] = 'project'
  end
end
