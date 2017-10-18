# Copyright © 2011-2017 MUSC Foundation for Research Development
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
  respond_to :js, :json, :html

  before_action :initialize_service_request,      except: [:approve_changes, :get_help, :feedback]
  before_action :validate_step,                   only:   [:protocol, :service_details, :service_calendar, :service_subsidy, :document_management, :review, :obtain_research_pricing, :confirmation, :save_and_exit]
  before_action :setup_navigation,                only:   [:navigate, :catalog, :protocol, :service_details, :service_calendar, :service_subsidy, :document_management, :review, :obtain_research_pricing, :confirmation]
  before_action :authorize_identity,              except: [:approve_changes, :get_help, :feedback, :show]
  before_action :authenticate_identity!,          except: [:catalog, :add_service, :remove_service, :get_help, :feedback]
  before_action :authorize_protocol_edit_request, only:   [:catalog]
  before_action :find_locked_org_ids,             only:   [:catalog]

  def show
    @protocol = @service_request.protocol
    @admin_offset = params[:admin_offset]
    @show_signature_section = params[:show_signature_section]
    @service_list_true = @service_request.service_list(true)
    @service_list_false = @service_request.service_list(false)
    @line_items = @service_request.line_items
    @display_all_services = params[:display_all_services] == 'true' ? true : false

    respond_to do |format|
      format.xlsx do
        render xlsx: "show", filename: "service_request_#{@protocol.id}", disposition: "inline"
      end
    end
  end

  def navigate
    case session[:current_location]
    when 'protocol'
      @service_request.group_valid?(:protocol)
    when 'service_details'
      @service_request.protocol.update_attributes(details_params) if @service_request.protocol && details_params
      @service_request.group_valid?(:service_details)
    when 'service_calendar'
      @service_request.group_valid?(:service_calendar)
    end

    @errors = @service_request.errors

    if @errors.any?
      render action: @page
    else
      ssr_id_params = @sub_service_request ? "?sub_service_request_id=#{@sub_service_request.id}" : ""
      redirect_to "/service_requests/#{@service_request.id}/#{@forward}" + ssr_id_params
    end
  end

  # service request wizard pages

  def catalog
    if @sub_service_request
      @institutions = Institution.where(id: @sub_service_request.organization.parents.select{|x| x.type == 'Institution'}.map(&:id))
    else
      @institutions = Institution.order('`order`')
    end

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
    @has_subsidy          = @sub_service_request ? @sub_service_request.has_subsidy? : @service_request.sub_service_requests.map(&:has_subsidy?).any?
    @eligible_for_subsidy = @sub_service_request ? @sub_service_request.eligible_for_subsidy? : @service_request.sub_service_requests.map(&:eligible_for_subsidy?).any?

    if !@has_subsidy && !@eligible_for_subsidy
      ssr_id_params = @sub_service_request ? "?sub_service_request_id=#{@sub_service_request.id}" : ""
      redirect_to "/service_requests/#{@service_request.id}/document_management" + ssr_id_params
    end
  end

  def document_management
    @notable_type         = 'Protocol'
    @notable_id           = @service_request.protocol_id
    @has_subsidy          = @service_request.sub_service_requests.map(&:has_subsidy?).any?
    @eligible_for_subsidy = @service_request.sub_service_requests.map(&:eligible_for_subsidy?).any?

    unless @has_subsidy || @eligible_for_subsidy
      @back = 'service_calendar'
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

    NotifierLogic.new(@service_request, @sub_service_request, current_user).update_status_and_send_get_a_cost_estimate_email
    render formats: [:html]
  end

  def confirmation
    @protocol = @service_request.protocol
    @service_request.previous_submitted_at = @service_request.submitted_at
    @display_all_services = true

    should_push_to_epic = @sub_service_request ? @sub_service_request.should_push_to_epic? : @service_request.should_push_to_epic?

    if should_push_to_epic && Setting.find_by_key("use_epic").value && @protocol.selected_for_epic
      # Send a notification to Lane et al to create users in Epic.  Once
      # that has been done, one of them will click a link which calls
      # approve_epic_rights.
      @protocol.ensure_epic_user
      if Setting.find_by_key("queue_epic").value
        EpicQueue.create(protocol_id: @protocol.id, identity_id: current_user.id) unless EpicQueue.where(protocol_id: @protocol.id).size == 1
      else
        @protocol.awaiting_approval_for_epic_push
        send_epic_notification_for_user_approval(@protocol)
      end
    end
    NotifierLogic.new(@service_request, @sub_service_request, current_user).update_ssrs_and_send_emails
    render formats: [:html]
  end

  def save_and_exit
    respond_to do |format|
      format.html {
        if @sub_service_request #if editing a sub service request, update status
          @sub_service_request.update_attribute(:status, 'draft')
        else
          @service_request.update_status('draft')
          @service_request.ensure_ssr_ids
        end
        redirect_to dashboard_root_path, sub_service_request_id: @sub_service_request.try(:id)
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
      @line_items_count     = (@sub_service_request || @service_request).line_items.count
      @sub_service_requests = @service_request.cart_sub_service_requests
    end
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
        NotifierLogic.new(@service_request, nil, current_user).ssr_deletion_emails(deleted_ssr: ssr, ssr_destroyed: true, request_amendment: false, admin_delete_ssr: false)
        ssr.destroy
      end
    end

    @service_request.reload

    @line_items_count     = (@sub_service_request || @service_request).line_items.count
    @sub_service_requests = @service_request.cart_sub_service_requests

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
          :recruitment_start_date, :recruitment_end_date).to_h

        # Finally, transform date attributes.
        date_attrs = %w(start_date end_date recruitment_start_date recruitment_end_date)
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

  # Each of these helper methods assigns session[:errors] to persist the errors through the
  # redirect_to so that the user has an explanation
  def validate_step
    case action_name
    when 'protocol'
      validate_catalog
    when -> (n) { ['service_details', 'save_and_exit'].include?(n) }
      validate_catalog && validate_protocol
    when 'service_calendar'
      validate_catalog && validate_protocol && validate_service_details
    else
      validate_catalog && validate_protocol && validate_service_details && validate_service_calendar
    end
  end

  def validate_catalog
    unless @service_request.group_valid?(:catalog)
      @service_request.errors.full_messages.each do |m|
        flash[:error] = m
      end
      redirect_to catalog_service_request_path(@service_request, sub_service_request_id: @sub_service_request.try(:id)) and return false
    end
    return true
  end

  def validate_protocol
    unless @service_request.group_valid?(:protocol)
      @service_request.errors.full_messages.each do |m|
        flash[:error] = m
      end
      redirect_to protocol_service_request_path(@service_request, sub_service_request_id: @sub_service_request.try(:id)) and return false
    end
    return true
  end

  def validate_service_details
    unless @service_request.group_valid?(:service_details)
      @service_request.errors.full_messages.each do |m|
        flash[:error] = m
      end
      redirect_to service_details_service_request_path(@service_request, sub_service_request_id: @sub_service_request.try(:id)) and return false
    end
    return true
  end

  def validate_service_calendar
    unless @service_request.group_valid?(:service_calendar)
      @service_request.errors.full_messages.each do |m|
        flash[:error] = m
      end
      redirect_to service_calendar_service_request_path(@service_request, sub_service_request_id: @sub_service_request.try(:id)) and return false
    end
    return true
  end

  def setup_navigation
    session[:current_location]  = action_name unless action_name == 'navigate'
    @page                       = session[:current_location]

    c = YAML.load_file(Rails.root.join('config', 'navigation.yml'))[@page]
    unless c.nil?
      @step_text   = c['step_text']
      @css_class   = c['css_class']
      @back        = c['back']
      @forward     = c['forward']
    end
  end

  def setup_catalog_calendar
    if Setting.find_by_key("use_google_calendar").value
      curTime = Time.now.utc
      startMin = curTime
      startMax  = (curTime + 1.month)

      @events = []
      begin
        path = Rails.root.join("tmp", "basic.ics")
        if path.exist?
          #to parse file and get events
          cal_file = File.open(path)

          cals = Icalendar.parse(cal_file)

          cal = cals.first

          events = cal.try(:events).try(:sort) { |x, y| y.dtstart <=> x.dtstart } || []

          events.each do |event|
            next if Time.parse(event.dtstart.to_s) > startMax
            break if Time.parse(event.dtstart.to_s) < startMin
            @events << create_calendar_event(event)
          end

          @events.reverse!
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
    if Setting.find_by_key("use_news_feed").value
      @news = []
      begin
        page = Nokogiri::HTML(open("https://www.sparcrequestblog.com"))
        articles = page.css('article.post').take(3)
        articles.each do |article|
          @news << {title: (article.at_css('.entry-title') ? article.at_css('.entry-title').text : ""),
                  link: (article.at_css('.entry-title a') ? article.at_css('.entry-title a')[:href] : ""),
                  date: (article.at_css('.date') ? article.at_css('.date').text : "") }
        end
      rescue Net::OpenTimeout
      end
    end
  end

  def ssr_has_changed?(service_request, sub_service_request) #specific ssr has changed?
    previously_submitted_at = service_request.previous_submitted_at.nil? ? Time.now.utc : service_request.previous_submitted_at.utc
    unless sub_service_request.audit_report(current_user, previously_submitted_at, Time.now.utc)[:line_items].empty?
      return true
    end
    return false
  end

  def service_request_has_changed_ssr?(service_request) #any ssr on sr has changed?
    service_request.sub_service_requests.each do |ssr|
      if ssr_has_changed?(service_request, ssr)
        return true
      end
    end
    return false
  end

  def send_epic_notification_for_user_approval(protocol)
    Notifier.notify_for_epic_user_approval(protocol).deliver unless Setting.find_by_key("queue_epic").value
  end

  def authorize_protocol_edit_request
    if current_user
      authorized  = if @sub_service_request
                      current_user.can_edit_sub_service_request?(@sub_service_request)
                    else
                      @service_request.status == 'first_draft' || current_user.can_edit_service_request?(@service_request)
                    end

      protocol = @sub_service_request ? @sub_service_request.protocol : @service_request.protocol

      unless authorized || protocol.project_roles.find_by(identity: current_user).present?
        @service_request     = nil
        @sub_service_request = nil

        render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to edit this Request.' }
      end
    end
  end

  def set_highlighted_link
    @highlighted_link ||= 'sparc_request'
  end
end
