class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :authenticate
  before_filter :set_service_request_id
  before_filter :load_defaults
  before_filter :setup_navigation

  def authenticate
    @current_user = Identity.find_by_ldap_uid 'anc63'
  end

  def set_service_request_id
    if params[:controller] == 'service_requests'
      #blow the session away if we aren't logged in and don't have a valid url
      session.delete(:service_request_id) unless @current_user and params[:id]

      if @current_user and params[:id]
        if sr = @current_user.protocol_service_requests.find(params[:id]) rescue false
          session[:service_request_id] = sr.id
        elsif (sr = @current_user.requested_service_requests.find(params[:id]) rescue false) and session[:first_draft]
          session[:service_request_id] = sr.id
        else
          render :text => 'get out'
        end
      elsif @current_user and not session[:service_request_id]
        sr = @current_user.requested_service_requests.new(:service_requester_id => @current_user.id)
        sr.save :validate => false

        session[:service_request_id] = sr.id
        session[:first_draft] = true
        redirect_to catalog_service_request_path(sr)
      else #we aren't logged in so let's do some funky stuff
        render :text => 'not logged in'
      end
    end
  end

  def load_defaults
    begin 
      @application_config ||= YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]
      @default_mail_to = @application_config['default_mail_to']
    rescue
      raise "application.yml not found, see config/application.yml.example"
    end
  end
      
  def setup_navigation
    page = params[:action] == 'navigate' ? request.referrer.split('/').last : params[:action]
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
