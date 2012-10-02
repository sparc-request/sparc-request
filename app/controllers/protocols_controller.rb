class ProtocolsController < ApplicationController
  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = Protocol.new
    @protocol.build_research_types
    @protocol.build_human_subjects
    @protocol.build_vertebrate_animals
    @protocol.build_investigational_products
    @protocol.build_ip_patents
    @protocol.build_study_types
    @protocol.build_impact_areas
    @protocol.build_affiliations  
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    puts "#"*50
    puts params.inspect
    puts "#"*50
    @protocol = Protocol.new params[:protocol]

    if @protocol.valid?
      @protocol.save
    else
      puts "#"*50
      puts @protocol.errors.inspect
      puts "#"*50

      render :text => @protocol.errors.inspect
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end
end
