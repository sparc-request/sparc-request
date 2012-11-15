class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :authenticate
  before_filter :load_defaults
  before_filter :setup_session
  before_filter :setup_navigation

  # for now we are assuming auto login
  def authenticate
    @current_user = Identity.find_by_ldap_uid 'jug2'

    #@current_user = nil #uncomment to test as if not logged in
    # let's do some cleanup if the user changes
    if @current_user and @current_user.id != session[:identity_id]
        session.delete(:service_request_id) 
        session.delete(:sub_service_request_id)
        session.delete(:first_draft)
    end

    session[:identity_id] = @current_user.id unless @current_user.nil?
  end

  def current_user
    Identity.find session[:identity_id]
  end
  
  def setup_session
    # set/get the objects we need to manipulate in other controllers
    @service_request = nil
    @sub_service_request = nil
    @line_items = nil

    if params[:controller] == 'service_requests'

      # we are starting a new service request
      unless params[:id]
        if session[:service_request_id] != params[:id].to_i # we are trying to access different service request, so we want to make sure we remove the first_draft session variable
          session.delete(:first_draft) 
        end
        
        session.delete(:service_request_id) 
        session.delete(:sub_service_request_id)
      end
     
      if @current_user and params[:id] # we are logged in and trying to access a service request
        
        # let's find the service requests with this id
        @service_request = @current_user.protocol_service_requests.where(:id => params[:id]).empty? ? @current_user.requested_service_requests.where(:id => params[:id]).first : @current_user.protocol_service_requests.where(:id => params[:id]).first

        if @service_request.nil? # we didn't find a service request for this user with the id supplied 
          error = "The service request you are trying to access can not be found <br /> or is not editable by you. <br />If you believe this is in error please contact, #{@error_contact}, and provide the following information:"
          error += "<br /> Reference #: SR#{params[:id]}"
          render :partial => 'service_requests/authorization_error', :locals => {:error => error}
        elsif !@current_user.can_edit_service_request? @service_request and !session[:first_draft] # the service requested isn't in a state that can be edited and we aren't working on a new service request
          error = "The service request you are trying to access is not editable. <br />If you believe this is in error please contact, #{@error_contact}, and provide the following information:"
          error += "<br /> Reference #: SR#{params[:id]}"
          render :partial => 'service_requests/authorization_error', :locals => {:error => error}
        else # otherwise let's grab the line items we need
          @line_items = @service_request.line_items
          session[:service_request_id] = @service_request.id
        end

        if !@service_request.nil? and (params[:sub_service_request_id] or session[:sub_service_request_id]) # we are trying to edit a sub service request
          session[:sub_service_request_id] = params[:sub_service_request_id] ? params[:sub_service_request_id] : session[:sub_service_request_id]
          @sub_service_request = @service_request.sub_service_requests.where(:id => session[:sub_service_request_id]).first

          if @sub_service_request.nil? # we didn't find a sub service request for the id supplied
            error = "The service request you are trying to access can not be found. <br />If you believe this is in error please contact, #{@error_contact}, and provide the following information:"
            error += "<br /> Reference #: SSR#{session[:sub_service_request_id]}"
            render :partial => 'service_requests/authorization_error', :locals => {:error => error}
          elsif !@current_user.can_edit_sub_service_request? @sub_service_request # the sub service request isn't ina  state that can be edited
            error = "The service request you are trying to access is not editable. <br />If you believe this is in error please contact, #{@error_contact}, and provide the following information:"
            error += "<br /> Reference #: SSR#{session[:sub_service_request_id]}"
            render :partial => 'service_requests/authorization_error', :locals => {:error => error}
          else #otherwise let's replace the line items we use with the ones provided by the service request
            @line_items = @sub_service_request.line_items
          end
        end
      elsif @current_user and not session[:service_request_id] # we are logged in and we want to create a new service request
        @service_request = @current_user.requested_service_requests.new(:service_requester_id => @current_user.id)
        if params[:protocol_id] # we want to create a new service request that belongs to an existing protocol
          if @current_user.protocols.where(:id => params[:protocol_id]).empty? # this user doesn't have permission to create service request under this protocol
            error = "You are attempting to create a service request under a study/project that you do not have permissions to access. <br />If you believe this is in error please contact, #{@error_contact}, and provide the following information:"
            error += "<br /> Reference #: PROTOCOL#{params[:protocol_id]}"
            render :partial => 'service_requests/authorization_error', :locals => {:error => error}
          else # otherwise associate the service request with this protocol
            @service_request.protocol_id = params[:protocol_id]
          end
        end

        @service_request.save :validate => false

        session[:service_request_id] = @service_request.id
        session[:first_draft] = true
        redirect_to catalog_service_request_path(@service_request)
      else #we aren't logged in so let's create a service request that doesn't have a requester.  one will be added once they click 'Submit Request'
        if session[:service_request_id]
          @service_request = ServiceRequest.find session[:service_request_id]
          @line_items = @service_request.line_items
        else
          @service_request = ServiceRequest.new
          @service_request.save :validate => false
          session[:first_draft] = true
          session[:service_request_id] = @service_request.id
          redirect_to catalog_service_request_path(@service_request)
        end

      end
    elsif ['search', 'service_calendars'].include? params[:controller]
      @service_request = ServiceRequest.find session[:service_request_id]
      if session[:sub_service_request_id]
        @sub_service_request = @service_request.sub_service_requests.find session[:sub_service_request_id]
        @line_items = @sub_service_request.line_items
      else
        @line_items = @service_request.line_items
      end
    end
  end

  def load_defaults
    begin 
      @application_config ||= YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]
      @default_mail_to = @application_config['default_mail_to']
      @user_portal_link = @application_config['user_portal_link']
      @error_contact = @application_config['error_contact']
      @application_title = @application_config['application_title']
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
