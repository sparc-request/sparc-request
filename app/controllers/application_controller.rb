class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :authenticate
  before_filter :setup_session
  before_filter :load_defaults
  before_filter :setup_navigation

  # for now we are assuming auto login
  def authenticate
    @current_user = Identity.find_by_ldap_uid 'jug2'
  end

  def current_user
    Identity.find_by_ldap_uid('anc63').id
  end
  
  def setup_session
    # set/get the objects we need to manipulate in other controllers
    @service_request = nil
    @sub_service_request = nil
    @line_items = nil
    @documents = nil

    if params[:controller] == 'service_requests'
      #blow the session away if we aren't logged in and don't have a valid url
      unless @current_user and params[:id]
        session.delete(:service_request_id) 
        session.delete(:sub_service_request_id)
      end
     
      if @current_user and params[:id]
        if @service_request = @current_user.protocol_service_requests.find(params[:id]) rescue false
          @line_items = @service_request.line_items
          @documents = @service_request.documents
          session[:service_request_id] = @service_request.id
        elsif (@service_request = @current_user.requested_service_requests.find(params[:id]) rescue false) and session[:first_draft]
          @line_items = @service_request.line_items
          @documents = @service_request.documents
          session[:service_request_id] = @service_request.id
        else
          render :text => 'You are not authorized to view this page'
        end

        if params[:sub_service_request_id] or session[:sub_service_request_id]
          session[:sub_service_request_id] = params[:sub_service_request_id] ? params[:sub_service_request_id] : session[:sub_service_request_id]
          @sub_service_request = @service_request.sub_service_requests.find session[:sub_service_request_id]

          @line_items = @sub_service_request.line_items
          @documents = @sub_service_request.documents
        end
      elsif @current_user and not session[:service_request_id]
        @service_request = @current_user.requested_service_requests.new(:service_requester_id => @current_user.id)
        @service_request.save :validate => false

        session[:service_request_id] = @service_request.id
        session[:first_draft] = true
        redirect_to catalog_service_request_path(@service_request)
      else #we aren't logged in so let's do some funky stuff
        render :text => 'You are not logged in'
      end
    elsif params[:controller] == 'search'
      @service_request = ServiceRequest.find session[:service_request_id]
      if session[:sub_service_request_id]
          @sub_service_request = @service_request.sub_service_requests.find session[:sub_service_request_id]
      end
    end
  end

  def load_defaults
    begin 
      @application_config ||= YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]
      @default_mail_to = @application_config['default_mail_to']
      @user_portal_link = @application_config['user_portal_link']
    rescue
      raise "application.yml not found, see config/application.yml.example"
    end
  end
      
  def setup_navigation
    #TODO - this could definitely be done a better way
    page = params[:action] == 'navigate' ? request.referrer.split('/').last.split('?').first : params[:action]
    c = YAML.load_file(Rails.root.join('config', 'navigation.yml'))[page]
    unless c.nil?
      @step_text = c['step_text']
      @css_class = c['css_class']
      @back = c['back']
      @catalog = c['catalog']
      @forward = c['forward']
      @validation_groups = c['validation_groups']
    end
  end
end
