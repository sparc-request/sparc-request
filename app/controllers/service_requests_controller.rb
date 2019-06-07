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

require 'generate_request_grant_billing_pdf'

class ServiceRequestsController < ApplicationController
  include ActionView::Helpers::TextHelper

  respond_to :js, :json, :html

  before_action :initialize_service_request,      except: [:approve_changes, :get_help, :feedback]
  before_action :validate_step,                   only:   [:navigate, :protocol, :service_details, :service_calendar, :service_subsidy, :document_management, :review, :obtain_research_pricing, :confirmation, :save_and_exit]
  before_action :find_cart_ssrs,                  only:   [:navigate, :catalog, :protocol, :service_details, :service_subsidy, :document_management]
  before_action :setup_navigation,                only:   [:navigate, :catalog, :protocol, :service_details, :service_calendar, :service_subsidy, :document_management, :review, :obtain_research_pricing, :confirmation]
  before_action :authorize_identity,              except: [:approve_changes, :get_help, :feedback, :show]
  before_action :authenticate_identity!,          except: [:catalog, :add_service, :remove_service, :get_help, :feedback]
  before_action :find_locked_org_ids,             only:   [:catalog]
  before_action :find_service,                    only:   [:catalog]

  def show
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id]) if params[:sub_service_request_id]
    @protocol = @service_request.protocol
    @admin_offset = params[:admin_offset]
    @show_signature_section = params[:show_signature_section]
    @service_list_true = @service_request.service_list(true)
    @service_list_false = @service_request.service_list(false)
    @line_items = @service_request.line_items
    @display_all_services = params[:display_all_services] == 'true' ? true : false

    @report_type = params[:report_type]
    respond_to do |format|
      format.xlsx do
        render xlsx: "#{@report_type}", filename: "service_request_#{@protocol.id}", disposition: "inline"
      end
    end
  end

  def navigate
    redirect_to @forward
  end

  # service request wizard pages

  def catalog
    @institutions = Institution.all

    setup_catalog_calendar
    setup_catalog_news_feed
  end

  def protocol
    @service_request.sub_service_requests.where(service_requester_id: nil).update_all(service_requester_id: current_user.id)
  end

  def service_details
    if @service_request.has_per_patient_per_visit_services? && @service_request.arms.empty?
        @service_request.protocol.arms.create(
          name: 'Screening Phase',
          visit_count: 1,
          new_with_draft: true
        )
    end
  end

  def service_calendar
    session[:service_calendar_pages] = params[:pages] if params[:pages]
  end

  def service_subsidy
    @has_subsidy          = @service_request.sub_service_requests.map(&:has_subsidy?).any?
    @eligible_for_subsidy = @service_request.sub_service_requests.map(&:eligible_for_subsidy?).any?

    if !@has_subsidy && !@eligible_for_subsidy
      redirect_to document_management_service_request_path(srid: @service_request.id)
    end
  end

  def document_management
    @notable_type         = 'Protocol'
    @notable_id           = @service_request.protocol_id
    @has_subsidy          = @service_request.sub_service_requests.map(&:has_subsidy?).any?
    @eligible_for_subsidy = @service_request.sub_service_requests.map(&:eligible_for_subsidy?).any?

    unless @has_subsidy || @eligible_for_subsidy
      @back = service_calendar_service_request_path(srid: @service_request.id)
    end
  end

  def review
    @notable_type = 'Protocol'
    @notable_id = @service_request.protocol_id
    @tab          = 'calendar'
    @review       = true
    @portal       = false
    @admin        = false
    @merged       = true
    @consolidated = false
    @display_all_services = true

    # Reset all the page numbers to 1 at the start of the review request
    # step.
    @pages = {}
    @service_request.arms.each do |arm|
      @pages[arm.id] = 1
    end
  end

  def obtain_research_pricing
    @protocol = @service_request.protocol
    @service_request.previous_submitted_at = @service_request.submitted_at

    NotifierLogic.new(@service_request, current_user).update_status_and_send_get_a_cost_estimate_email
    render formats: [:html]
  end

  def confirmation
    @protocol = @service_request.protocol
    @service_request.previous_submitted_at = @service_request.submitted_at
    @display_all_services = true

    if @service_request.should_push_to_epic? && Setting.get_value("use_epic") && @protocol.selected_for_epic
      # Send a notification to Lane et al to create users in Epic.  Once
      # that has been done, one of them will click a link which calls
      # approve_epic_rights.
      @protocol.ensure_epic_user
      if Setting.get_value("queue_epic")
        EpicQueue.create(protocol_id: @protocol.id, identity_id: current_user.id) if should_queue_epic?(@protocol)
      else
        @protocol.awaiting_approval_for_epic_push
        send_epic_notification_for_user_approval(@protocol)
      end
    end
    NotifierLogic.new(@service_request, current_user).update_ssrs_and_send_emails
    render formats: [:html]
  end

  def save_and_exit
    respond_to do |format|
      format.html {
        @service_request.update_status('draft')
        @service_request.ensure_ssr_ids
        redirect_to dashboard_root_path
      }
      format.js
    end
  end

  def add_service
    add_service = AddService.new(@service_request,
                                 params[:service_id].to_i,
                                 current_user
                                )
    add_service.existing_service_ids
    if add_service.existing_service_ids.include?( params[:service_id].to_i )
      @duplicate_service = true
    else
      add_service.generate_new_service_request
    end

    @service_request.reload

    @line_items_count = @service_request.line_items.count
    find_cart_ssrs
  end

  def remove_service
    line_item = @service_request.line_items.find(params[:line_item_id])
    ssr       = line_item.sub_service_request

    if ssr.can_be_edited?
      @service_request.line_items.where(service: line_item.service.related_services).update_all(optional: true)

      line_item.destroy

      ssr.update_attribute(:status, 'draft') unless ssr.status == 'first_draft'
      @service_request.reload

      if ssr.line_items.empty?
        NotifierLogic.new(@service_request, current_user).ssr_deletion_emails(deleted_ssr: ssr, ssr_destroyed: true, request_amendment: false, admin_delete_ssr: false)
        ssr.destroy
      end
    end

    @service_request.reload

    @line_items_count = @service_request.line_items.count
    find_cart_ssrs

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def get_help
  end

  def feedback
    feedback = Feedback.new(feedback_params)
    if feedback.save
      Notifier.provide_feedback(feedback).deliver_now
      flash.now[:success] = t(:proper)[:right_navigation][:feedback][:submitted]
    else
      @errors = feedback.errors
    end
  end

  def approve_changes
    @service_request = ServiceRequest.find params[:id]
    @approval = @service_request.approvals.where(id: params[:approval_id]).first
    @previously_approved = true

    if @approval and @approval.identity.nil?
      @approval.update_attributes(identity_id: current_user.id, approval_date: Time.now)
      @previously_approved = false
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:email, :message)
  end

  def details_params
    @details_params ||= begin
      required_keys = params[:study] ? :study : params[:project] ? :project : nil
      if required_keys.present?
        temp = params.require(required_keys).permit(:start_date, :end_date,
          :recruitment_start_date, :recruitment_end_date, :initial_budget_sponsor_received_date, :budget_agreed_upon_date, :initial_amount, :negotiated_amount, :initial_amount_clinical_services, :negotiated_amount_clinical_services).to_h

        # Finally, transform date attributes.
        date_attrs = %w(start_date end_date recruitment_start_date recruitment_end_date initial_budget_sponsor_received_date budget_agreed_upon_date)
        temp.inject({}) do |h, (k, v)|
          if date_attrs.include?(k) && v.present?
            h.merge(k => Time.strptime(v, "%m/%d/%Y"))
          else
            h.merge(k => v)
          end
        end
      end
    end
  end

  def current_page
    action_name == 'navigate' ? Rails.application.routes.recognize_path(request.referrer)[:action] : action_name
  end

  def find_cart_ssrs
    @sub_service_requests = @service_request.cart_sub_service_requests
  end

  def validate_step
    case current_page
    when -> (n) { ['protocol', 'save_and_exit'].include?(n) }
      validate_catalog && validate_protocol
    when 'service_details'
      validate_catalog && validate_protocol && validate_service_details
    else
      validate_catalog && validate_protocol && validate_service_details && validate_service_calendar
    end
  end

  def validate_catalog
    unless @service_request.group_valid?(:catalog)
      redirect_to catalog_service_request_path(srid: @service_request.id) and return false unless action_name == 'catalog'
      @errors = @service_request.errors
    end
    return true
  end

  def validate_protocol
    unless @service_request.group_valid?(:protocol)
      redirect_to protocol_service_request_path(srid: @service_request.id) and return false unless action_name == 'protocol'
      @errors = @service_request.errors
    end
    return true
  end

  def validate_service_details
    @service_request.protocol.update_attributes(details_params) if details_params

    unless @service_request.group_valid?(:service_details)
      redirect_to service_details_service_request_path(srid: @service_request.id, navigate: 'true') and return false unless action_name == 'service_details'
      @errors = @service_request.errors
    end
    return true
  end

  def validate_service_calendar
    unless @service_request.group_valid?(:service_calendar)
      redirect_to service_calendar_service_request_path(srid: @service_request.id, navigate: 'true') and return false unless action_name == 'service_calendar'
      @errors = @service_request.errors
    end
    return true
  end

  def setup_navigation
    if c = YAML.load_file(Rails.root.join('config', 'navigation.yml'))[current_page]
      @step_text   = c['step_text']
      @css_class   = c['css_class']
      @back        = eval("#{c['back']}_service_request_path(srid: #{@service_request.id})") if c['back']
      @forward     = eval("#{c['forward']}_service_request_path(srid: #{@service_request.id})") if c['forward']
    end
  end

  def create_calendar_event event, occurence
    all_day     = !occurence.start_time.to_s.include?("UTC")
    start_time  = Time.parse(occurence.start_time.to_s).in_time_zone("Eastern Time (US & Canada)")
    end_time    = Time.parse(occurence.end_time.to_s).in_time_zone("Eastern Time (US & Canada)")
    {
      month:          start_time.strftime("%b"),
      day:            start_time.day,
      title:          event.summary,
      description:    simple_format(event.description).gsub(URI::regexp(%w(http https)), '<a href="\0" target="_blank">\0</a>'),
      all_day:        all_day,
      start_time:     start_time.strftime("%l:%M %p"),
      end_time:       end_time.strftime("%l:%M %p"),
      sort_by_start:  start_time.strftime("%Y%m%d"),
      where:          event.location
    }
  end


  def setup_catalog_calendar
    if Setting.get_value("use_google_calendar")
      curTime   = Time.now.utc
      startMin  = curTime
      startMax  = (curTime + 1.month)

      @events = []
      begin
        path = Rails.root.join("tmp", "basic.ics")
        if path.exist?
          #to parse file and get events
          cal_file = File.open(path)

          cals = Icalendar::Calendar.parse(cal_file)

          cal = cals.first

          cal.events.each do |event|
            if event.occurrences_between(startMin, startMax).present?
              event.occurrences_between(startMin, startMax).each do |occurence|
                @events << create_calendar_event(event, occurence)
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

  def setup_catalog_news_feed
    if Setting.get_value("use_news_feed")
      @news =
        if Setting.get_value("use_news_feed_api")
          NewsFeed.const_get("#{Setting.get_value("news_feed_api")}Adapter").new.posts
        else
          @news = NewsFeed::PageParser.new.posts
        end
    end
  end

  def send_epic_notification_for_user_approval(protocol)
    Notifier.notify_for_epic_user_approval(protocol).deliver unless Setting.get_value("queue_epic")
  end

  def set_highlighted_link
    @highlighted_link ||= 'sparc_request'
  end

  def should_queue_epic?(protocol)
    queues = EpicQueue.where(protocol_id: protocol.id)
    if (queues.size == 1)
      queues.first.update_attributes(user_change: false)
      return false
    else
      return true
    end
  end

  def find_service
    if params[:service_id]
      @service  = Service.find(params[:service_id])
      @provider = @service.provider
      @program  = @service.program
      @core     = @service.core

      redirect_to catalog_service_request_path(srid: @service_request.id) unless @service.is_available?
    end
  end
end
