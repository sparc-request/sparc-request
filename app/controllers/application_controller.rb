# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  helper_method :current_user
  helper_method :xeditable?
  before_filter :setup_navigation
  before_filter :set_highlighted_link  # default is to not highlight a link
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def set_highlighted_link  # default value, override inside controllers
    @highlighted_link ||= ''
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|  u.permit!}
  end

  def current_user
    current_identity
  end

  def prepare_catalog
    if session['sub_service_request_id'] and @sub_service_request
      @institutions = @sub_service_request.organization.parents.select{|x| x.type == 'Institution'}
    else
      @institutions = Institution.order('`order`')
    end

    if USE_GOOGLE_CALENDAR
      curTime = Time.now.utc
      startMin = curTime
      startMax  = (curTime + 1.month)

      @events = []
      begin
        #to parse file and get events
        cal_file = File.open(Rails.root.join("tmp", "basic.ics"))

        cals = Icalendar.parse(cal_file)

        cal = cals.first

        events = cal.events.sort { |x, y| y.dtstart <=> x.dtstart }

        events.each do |event|
          next if Time.parse(event.dtstart.to_s) > startMax
          break if Time.parse(event.dtstart.to_s) < startMin
          @events << create_calendar_event(event)
        end

        @events.reverse!

        Alert.where(alert_type: ALERT_TYPES['google_calendar'], status: ALERT_STATUSES['active']).update_all(status: ALERT_STATUSES['clear'])
      rescue Exception => e
        active_alert = Alert.where(alert_type: ALERT_TYPES['google_calendar'], status: ALERT_STATUSES['active']).first_or_initialize
        if Rails.env == 'production' && active_alert.new_record?
          active_alert.save
          ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver unless request.remote_ip == '128.23.150.107' # this is an ignored IP address, MUSC security causes issues when they pressure test,  this should be extracted/configurable
        end
      end
    end

    if USE_NEWS_FEED
      page = Nokogiri::HTML(open("https://www.sparcrequestblog.com"))
      articles = page.css('article.post').take(3)
      @news = []
      articles.each do |article|
        @news << {title: (article.at_css('.entry-title') ? article.at_css('.entry-title').text : ""),
                  link: (article.at_css('.entry-title a') ? article.at_css('.entry-title a')[:href] : ""),
                  date: (article.at_css('.date') ? article.at_css('.date').text : "") }
      end
    end
  end

  def create_calendar_event event
    all_day = !event.dtstart.to_s.include?("UTC")
    start_time = Time.parse(event.dtstart.to_s).in_time_zone("Eastern Time (US & Canada)")
    end_time = Time.parse(event.dtend.to_s).in_time_zone("Eastern Time (US & Canada)")
    { month: start_time.strftime("%b"),
      day: start_time.day,
      title: event.summary,
      all_day: all_day,
      start_time: start_time.strftime("%l:%M %p"),
      end_time: end_time.strftime("%l:%M %p"),
      where: event.location
    }
  end


  def authorization_error msg, ref
    error = msg
    error += "<br />If you believe this is in error please contact, #{I18n.t 'error_contact'}, and provide the following information:"
    error += "<br /> Reference #: "
    error += ref

    render partial: 'service_requests/authorization_error', locals: { error: error }
  end

  def clean_errors errors
    errors.to_a.map {|k,v| "#{k.humanize} #{v}".rstrip + '.'}
  end

  def clean_messages errors
    errors.map {|k,v| v}.flatten
  end

  # Initialize the instance variables used with service requests:
  #   @service_request
  #   @sub_service_request
  #   @line_items
  #
  # These variables are initialized from params (if set) or cookies.
  def initialize_service_request
    @service_request = nil
    @sub_service_request = nil
    @line_items = nil

    if params[:edit_original]
      # If editing the original service request, we delete the sub
      # service request id (remember, a sub service request is a service
      # request that has been split out).
      session.delete(:sub_service_request_id)
    end

    if params[:controller] == 'service_requests'
      if params[:action] == 'catalog' and params[:id].nil?
        # Catalog is the main service requests page; this is where the
        # service request is first created.  We will create the service
        # request in a moment.
        #
        # If the "go back" button is used, then params[:id] will be
        # non-nil, and we will not create a new service request.
        session.delete(:service_request_id)
        session.delete(:sub_service_request_id)
      else
        # For all other service request controller actions, we go ahead
        # and set the cookie.
        session[:service_request_id] = params[:id] if params[:id]
        session[:sub_service_request_id] = params[:sub_service_request_id] if params[:sub_service_request_id]
      end

      if session[:service_request_id]
        # If the cookie is non-nil, then lookup the service request.  If
        # the service request is not found, display an error.
        use_existing_service_request
        validate_existing_service_request
      elsif params[:from_portal]
        session[:from_portal] = params[:from_portal]
        create_or_use_request_from_portal(params)
      else
        # If the cookie is nil (as with visiting the main catalog for
        # the first time), then create a new service request.
        create_new_service_request
        session.delete(:from_portal)
      end
    elsif params[:controller] == 'devise/sessions'
      if session[:service_request_id]
        use_existing_service_request
      else
        @service_request = ServiceRequest.new(status: 'first_draft')
        @service_request.save(validate: false)
        @line_items = []
        session[:service_request_id] = @service_request.id
      end
    else
      # For controllers other than the service requests controller, we
      # look up the service request, but do not display any errors.
      use_existing_service_request
    end
  end

  # If a request is initiated by clicking the 'Add Services' button in user
  # portal, we need to set it to 'draft' status. If we already have a draft
  # request created this way, use that one
  def create_or_use_request_from_portal(params)
    protocol = Protocol.find(params[:protocol_id].to_i)
    if (params[:has_draft] == 'true')
      @service_request = protocol.service_requests.last
      @line_items = @service_request.try(:line_items)
      @sub_service_request = @service_request.sub_service_requests.last
      session[:service_request_id] = @service_request.id
      if @sub_service_request
        session[:sub_service_request_id] = @sub_service_request.id
      end
    else
      create_new_service_request(true)
    end
  end

  # Set @service_request, @sub_service_request, and @line_items from the
  # ids stored in the session.
  def use_existing_service_request
    @service_request = ServiceRequest.find session[:service_request_id]
    if session[:sub_service_request_id]
      @sub_service_request = @service_request.sub_service_requests.find session[:sub_service_request_id]
      @line_items = @sub_service_request.try(:line_items)
    else
      @line_items = @service_request.try(:line_items)
    end
  end

  # Validate @service_request and @sub_service_request (after having
  # been set by use_existing_service_request).  Renders an error page if
  # they were not found.
  #
  # NOTE: If use_existing_service_request cannot find the ServiceRequest
  # or SubServiceRequest, it will throw an error, not render a friendly
  # authorization_error. So how is this being used?
  def validate_existing_service_request
    if @service_request.nil?
      authorization_error "The service request you are trying to access can not be found.",
                          "SR#{params[:id]}"
    elsif session[:sub_service_request_id] and @sub_service_request.nil?
      authorization_error "The service request you are trying to access can not be found.",
                          "SSR#{params[:sub_service_request_id]}"
    end
  end

  # Create a new service request and assign it to @service_request.
  def create_new_service_request(from_portal=false)
    status = from_portal ? 'draft' : 'first_draft'
    @service_request = ServiceRequest.new(status: status)

    if params[:protocol_id] # we want to create a new service request that belongs to an existing protocol
      if current_user and current_user.protocols.where(id: params[:protocol_id]).empty? # this user doesn't have permission to create service request under this protocol
        authorization_error "You are attempting to create a service request under a study/project that you do not have permissions to access.",
                            "PROTOCOL#{params[:protocol_id]}"
      else # otherwise associate the service request with this protocol
        @service_request.protocol_id = params[:protocol_id]
        @service_request.sub_service_requests.update_all(service_requester_id: current_user.id)
      end
    end

    # if the user has requested an account and it is pending approval we need to change the login message
    signed_up_but_not_approved = false
    if flash[:notice] == I18n.t("devise.registrations.identity.signed_up_but_not_approved") # use the local version of the text
      signed_up_but_not_approved = true
    end

    @service_request.save(validate: false)
    session[:service_request_id] = @service_request.id
    redirect_to catalog_service_request_path(@service_request, signed_up_but_not_approved: signed_up_but_not_approved)
  end

  def authorize_identity
    # can the user edit the service request
    # can the user edit the sub service request

    # we have a current user
    if current_user
      if @sub_service_request.nil? and (@service_request.status == 'first_draft' || current_user.can_edit_service_request?(@service_request))
        return true
      elsif @sub_service_request and current_user.can_edit_sub_service_request?(@sub_service_request)
        return true
      end
    # the service request is in first draft and has yet to be submitted (catalog page only)
    elsif @service_request.status == 'first_draft'
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
    @page = if params[:action] == 'navigate'
        params[:action] = params[:current_location] || request.referrer.split('/').last.split('?').first
      else
        params[:action]
      end


    c = YAML.load_file(Rails.root.join('config', 'navigation.yml'))[@page]
    unless c.nil?
      @step_text = c['step_text']
      @css_class = c['css_class']
      @back = c['back']
      @catalog = c['catalog']
      @forward = c['forward']
      @validation_groups = c['validation_groups']
    end
  end

  def xeditable? object=nil
    true
  end
end
