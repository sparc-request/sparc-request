class ProtocolsController < ApplicationController
  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = Protocol.new
    @protocol.build_research_types_info
    @protocol.build_human_subjects_info
    @protocol.build_vertebrate_animals_info
    @protocol.build_investigational_products_info
    @protocol.build_ip_patents_info
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
