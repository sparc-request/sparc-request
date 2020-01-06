# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  include ActionView::Helpers::TextHelper

  protect_from_forgery prepend: true

  helper :all

  helper_method :current_user

  before_action :preload_database_values
  before_action :set_highlighted_link
  before_action :get_news_feed,               if: Proc.new{ request.format.html? }
  before_action :get_calendar_events,         if: Proc.new{ request.format.html? }
  before_action :configure_permitted_params,  if: :devise_controller?

  protected

  ##############################
  ### Devise-Related Methods ###
  ##############################

  def current_user
    current_identity
  end

  def redirect_to_login
    flash[:alert] = t(:devise)[:failure][:unauthenticated]
    redirect_to identity_session_path
  end

  def after_sign_in_path_for(resource)
    initialize_service_request
    stored_location_for(resource) || root_path(srid: @service_request.try(:id))
  end

  def after_sign_out_path_for(resource)
    initialize_service_request
    root_path(srid: @service_request.try(:id))
  end

  def configure_permitted_params
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit! }
  end

  #############################
  ### Before-Action Methods ###
  #############################

  def preload_database_values
    Setting.preload_values
    PermissibleValue.preload_values
  end

  def set_highlighted_link  # default value, override inside controllers
    @highlighted_link ||= ''
  end

  def get_news_feed
    if Setting.get_value("use_news_feed")
      @news =
        if Setting.get_value("use_news_feed_api")
          NewsFeed.const_get("#{Setting.get_value("news_feed_api")}Adapter").new.posts
        else
          @news = NewsFeed::PageParser.new.posts
        end
    end
  end

  def get_calendar_events
    if Setting.get_value("use_google_calendar")
      curTime   = Time.now.utc
      startMin  = curTime
      startMax  = (curTime + 1.month)

      @events = []
      begin
        path = Rails.root.join("tmp", "basic.ics")
        if path.exist?
          cal_file  = File.open(path)
          cals      = Icalendar::Calendar.parse(cal_file)
          cal       = cals.first

          # Use index like an ID to view more information
          index = 0
          cal.events.each do |event|
            if event.occurrences_between(startMin, startMax).present?
              event.occurrences_between(startMin, startMax).each do |occurrence|
                @events << create_calendar_event(event, occurrence, index)
                index += 1
              end
            end
          end

          if @events.present?
            @events.sort!{ |x, y| y[:sort_by_start].to_i <=> x[:sort_by_start].to_i }
            @events.reverse!
          end

          Alert.where(alert_type: ALERT_TYPES['google_calendar'], status: ALERT_STATUSES['active']).update_all(status: ALERT_STATUSES['clear'])
        end
      rescue Exception, ArgumentError => e
        active_alert = Alert.where(alert_type: ALERT_TYPES['google_calendar'], status: ALERT_STATUSES['active']).first_or_initialize
        if Rails.env == 'production' && active_alert.new_record?
          active_alert.save
          ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver unless request.remote_ip == '128.23.150.107' # this is an ignored IP address, MUSC security causes issues when they pressure test,  this should be extracted/configurable
        end
      end
    end
  end

  def create_calendar_event(event, occurrence, index)
    all_day     = !occurrence.start_time.to_s.include?("UTC")
    start_time  = DateTime.parse(occurrence.start_time.to_s).in_time_zone("Eastern Time (US & Canada)")
    end_time    = DateTime.parse(occurrence.end_time.to_s).in_time_zone("Eastern Time (US & Canada)")
    {
      index:          index,
      title:          event.summary,
      description:    simple_format(event.description).gsub(URI::regexp(%w(http https)), '<a href="\0" target="blank">\0</a>'),
      date:           start_time.strftime("%A, %B %d"),
      time:           all_day ? t('layout.navigation.events.all_day') : [start_time.strftime("%l:%M %p"), end_time.strftime("%l:%M %p")].join(' - '),
      where:          event.location,
      month:          start_time.strftime("%b"),
      day:            start_time.day,
      sort_by_start:  start_time.strftime("%Y%m%d")
    }
  end

  #####################
  ### Other Methods ###
  #####################

  def authorization_error(msg=t('error_pages.authorization_error.error'), ref=nil)
    error   = msg + t('error_pages.authorization_error.contact', email: Setting.get_value('contact_us_cc'))
    error  += t('error_pages.authorization_error.reference', ref: ref) if ref

    redirect_to authorization_error_path(error: error, format: request.format.html? ? :html : :js)
  end

  def initialize_service_request
    if params[:srid].present?
      @service_request = ServiceRequest.find(params[:srid])
    else
      @service_request = ServiceRequest.new(status: 'first_draft')
    end
  end

  def authorize_identity
    # If the request is in first_draft status

    if @service_request.status == 'first_draft' && (action_name == 'catalog' || (helpers.request_referrer_action == 'catalog' && (request.format.js? || request.format.json?)))
      return true
    elsif current_user && current_user.can_edit_service_request?(@service_request)
      return true
    elsif !identity_signed_in?
      store_location_for(:identity, request.get? && request.format.html? ? request.url : request.referrer)
      authenticate_identity!
      return true
    end

    authorization_error("The service request you are trying to access is not editable.", "SR#{params[:id]}")
  end

  def in_dashboard?
    @in_dashboard ||= helpers.in_dashboard?

    in_admin?

    @in_dashboard
  end

  def in_admin?
    @in_admin ||= helpers.in_admin?
  end

  def authorize_dashboard_access
    if params[:ssrid]
      authorize_admin
    else
      authorize_protocol
    end
  end

  def authorize_protocol
    @service_request    = ServiceRequest.find(params[:srid]) if params[:srid]
    @protocol           = @service_request ? @service_request.protocol : Protocol.find(params[:protocol_id])
    permission_to_view  = current_user.can_view_protocol?(@protocol)

    unless permission_to_view || Protocol.for_admin(current_user.id).include?(@protocol)
      authorization_error('You are not allowed to access this Sub Service Request.')
    end
  end

  def authorize_admin
    if current_user
      @sub_service_request ||= SubServiceRequest.find(params[:ssrid])
      @service_request     = @sub_service_request.service_request
      unless (current_user.authorized_admin_organizations & @sub_service_request.org_tree).any?
        authorization_error('You are not allowed to access this Sub Service Request.')
      end
    else
      redirect_to_login
    end
  end

  def authorize_overlord
    if current_user
      unless current_user.catalog_overlord?
        authorization_error
      end
    else
      redirect_to_login
    end
  end

  def authorize_funding_admin
    redirect_to root_path unless Setting.get_value("use_funding_module") && current_user.is_funding_admin?
  end

  def sanitize_date(date)
    return Date.strptime(date, '%m/%d/%Y').to_s rescue Date.strptime(date, '%Y-%m-%d').to_s rescue ""
  end

  def sanitize_phone(phone)
    return phone.gsub(/\(|\)|-|\s/, '').gsub(I18n.t('constants.phone.extension'), '#') rescue ""
  end

  # More Specific Helpers #

  def setup_calendar_pages
    @pages  = {}
    @page   = params[:page].try(:to_i) || 1
    arm_id  = params[:arm_id].to_i if params[:arm_id]
    @arm    = Arm.find(arm_id) if arm_id

    session[:service_calendar_pages]          = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id]  = @page if @page && arm_id

    @service_request.arms.each do |arm|
      new_page        = (session[:service_calendar_pages].nil? || session[:service_calendar_pages][arm.id].nil?) ? 1 : session[:service_calendar_pages][arm.id]
      @pages[arm.id]  = @service_request.set_visit_page(new_page, arm)
    end
  end

  def find_locked_org_ids
    @locked_org_ids = @service_request.sub_service_requests.eager_load(organization: { org_children: :org_children }).select(&:is_locked?).reject(&:is_complete?).map{ |ssr| [ssr.organization_id, ssr.organization.all_child_organizations_with_self.map(&:id)] }.flatten.uniq
  end
end
