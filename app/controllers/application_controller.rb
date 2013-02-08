class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  helper_method :current_user

  before_filter :setup_navigation

  def current_user
    current_identity
  end
  
  def authorization_error msg, ref
    error = msg
    error += "<br />If you believe this is in error please contact, #{I18n.t 'error_contact'}, and provide the following information:"
    error += "<br /> Reference #: "
    error += ref
    render :partial => 'service_requests/authorization_error', :locals => {:error => error}
  end

  def initialize_service_request
    @service_request = nil
    @sub_service_request = nil
    @line_items = nil

    if params[:edit_original]
      session.delete(:sub_service_request_id)
    end

    if params[:controller] == 'service_requests'
      if params[:action] == 'catalog' and params[:id].nil?
        session.delete(:service_request_id)
        session.delete(:sub_service_request_id)
      else
        session[:service_request_id] = params[:id] if params[:id]
      end

      if session[:service_request_id]
        @service_request = ServiceRequest.where(:id => session[:service_request_id]).first

        if @service_request.nil?
          authorization_error "The service request you are trying to access can not be found.", "SR#{params[:id]}"
        else
          @line_items = @service_request.line_items
          
          if params[:sub_service_request_id] or session[:sub_service_request_id]
            session[:sub_service_request_id] = params[:sub_service_request_id] if params[:sub_service_request_id]
            @sub_service_request = SubServiceRequest.where(:id => session[:sub_service_request_id]).first
            
            if @sub_service_request.nil?
              authorization_error "The service request you are trying to access can not be found.", 
                                  "SSR#{params[:sub_service_request_id]}"
            else
              @line_items = @sub_service_request.line_items
            end
          end
        end
      else # we need to create a new service request
        @service_request = ServiceRequest.new :status => 'first_draft'
        if params[:protocol_id] # we want to create a new service request that belongs to an existing protocol
          if current_user and current_user.protocols.where(:id => params[:protocol_id]).empty? # this user doesn't have permission to create service request under this protocol
            authorization_error "You are attempting to create a service request under a study/project that you do not have permissions to access.",
                                "PROTOCOL#{params[:protocol_id]}"
          else # otherwise associate the service request with this protocol
            @service_request.protocol_id = params[:protocol_id]
          end
        end

        # if the user has requested an account and it is pending approval we need to change the login message
        signed_up_but_not_approved = false
        if flash[:notice] == I18n.t("devise.registrations.identity.signed_up_but_not_approved") # use the local version of the text
          signed_up_but_not_approved = true
        end

        @service_request.save :validate => false
        session[:service_request_id] = @service_request.id
        redirect_to catalog_service_request_path(@service_request, :signed_up_but_not_approved => signed_up_but_not_approved)
      end
    else
      @service_request = ServiceRequest.find session[:service_request_id]
      if session[:sub_service_request_id]
        @sub_service_request = @service_request.sub_service_requests.find session[:sub_service_request_id]
        @line_items = @sub_service_request.line_items
      else
        @line_items = @service_request.line_items
      end
    end
  end

  def authorize_identity
    # can the user edit the service request
    # can the user edit the sub service request
 
    # we have a current user
    if current_user
      if @sub_service_request.nil? and current_user.can_edit_service_request? @service_request
        return true
      elsif @sub_service_request and current_user.can_edit_sub_service_request? @sub_service_request
        return true
      end

    # the service request is in first draft and has yet to be submitted (catalog page only)
    elsif @service_request.status == 'first_draft' and @service_request.service_requester_id.nil?
      return true
    elsif !@service_request.status.nil? # this is a previous service request so we should attempt to sign in
      authenticate_identity! 
      return true
    end
    
    if @sub_service_request.nil?
      authorization_error "The service request you are trying to access is not editable.",
                          "SR#{session[:service_request_id]}"
    else
      authorization_error "The service request you are trying to access is not editable.",
                          "SSR#{session[:sub_service_request_id]}"
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
