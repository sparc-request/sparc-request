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
# A request amendment email is sent to service providers
# and admin of ssrs that have had services added/deleted and have been previously submitted
class NotifierLogic

  def initialize(service_request, sub_service_request, current_user)
    @service_request = service_request
    @current_user = current_user
    @sub_service_request = sub_service_request
    # Grab ssrs that have been previously submitted
    # Setting this to an array is necessary to grab the correct ssrs
    @previously_submitted_ssrs = @service_request.previously_submitted_ssrs
    # Flag for authorized users: when a new service has been added from
    # a new ssr, only send the request amendment and not the initial confirmation email
    @send_request_amendment_and_not_initial = @service_request.original_submitted_date.present? && !@previously_submitted_ssrs.empty?
  end

  def update_ssrs_and_send_emails
    @to_notify = []
    if @sub_service_request
      @to_notify << @sub_service_request.id unless @sub_service_request.status == 'submitted' || @sub_service_request.previously_submitted?
      @sub_service_request.update_attribute(:submitted_at, Time.now) unless @sub_service_request.status == 'submitted'

      @sub_service_request.update_attributes(status: 'submitted', nursing_nutrition_approved: false,
                                             lab_approved: false, imaging_approved: false, committee_approved: false) if UPDATABLE_STATUSES.include?(@sub_service_request.status)
    else
      @to_notify = update_service_request_status('submitted', true, true)

      @service_request.update_arm_minimum_counts
      @service_request.sub_service_requests.update_all(nursing_nutrition_approved: false, lab_approved: false, imaging_approved: false, committee_approved: false)
    end
    send_request_amendment_email_evaluation
    send_confirmation_notifications_submitted
  end

  def send_request_amendment_email_evaluation
    if !@previously_submitted_ssrs.empty?
      request_amendment_ssrs = @previously_submitted_ssrs.select{ |ssr| ssr_has_changed?(ssr) }

      destroyed_or_created_ssr = @service_request.previous_submitted_at.nil? ? [] : [@service_request.deleted_ssrs_since_previous_submission, @service_request.created_ssrs_since_previous_submission].flatten
      # If an existing SSR has had services added/deleted, send a request amendment 
      # (If an SSR has been deleted or created, this is also seen in the email)
      # The destroyed_or_created_ssr determines whether authorized users need a request amendment email 
      # regarding the destroyed or newly created SSR
      if !request_amendment_ssrs.empty?
        send_request_amendment(request_amendment_ssrs)
      elsif !destroyed_or_created_ssr.empty?
        send_user_notifications(request_amendment: true)
      end
    end
  end

  def send_confirmation_notifications_get_a_cost_estimate
    to_notify = []
    if @sub_service_request
      to_notify << @sub_service_request.id unless @sub_service_request.status == 'get_a_cost_estimate'

      @sub_service_request.update_attribute(:status, 'get_a_cost_estimate')
    else
      to_notify = update_service_request_status('get_a_cost_estimate')
    end

    if @sub_service_request && to_notify.include?(@sub_service_request.id)
      send_user_notifications(request_amendment: false)
      send_admin_notifications([@sub_service_request], request_amendment: false)
      send_service_provider_notifications([@sub_service_request], request_amendment: false)
    else
      sub_service_requests = @service_request.sub_service_requests.where(id: to_notify)
      if !sub_service_requests.empty? # if nothing is set to notify then we shouldn't send out e-mails
        send_user_notifications(request_amendment: false)
        send_admin_notifications(sub_service_requests, request_amendment: false)
        send_service_provider_notifications(sub_service_requests, request_amendment: false)
      end
    end
  end

  def send_confirmation_notifications_submitted
    if !@to_notify.empty?
      if @sub_service_request && @to_notify.include?(@sub_service_request.id)
        send_notifications([@sub_service_request])
      else
        sub_service_requests = @service_request.sub_service_requests.where(id: @to_notify)
        send_notifications(sub_service_requests) unless sub_service_requests.empty? # if nothing is set to notify then we shouldn't send out e-mails
      end
    end
  end

  def send_ssr_service_provider_notifications(sub_service_request, ssr_destroyed: false, request_amendment: false) #single sub-service request
    previously_submitted_at = sub_service_request.service_request.previous_submitted_at.nil? ? Time.now.utc : sub_service_request.service_request.previous_submitted_at.utc
    audit_report = request_amendment ? sub_service_request.audit_report(@current_user, previously_submitted_at, Time.now.utc) : nil

    sub_service_request.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)").each do |service_provider|
      send_individual_service_provider_notification(sub_service_request, service_provider, audit_report, ssr_destroyed, request_amendment)
    end
  end

  def send_admin_notifications(sub_service_requests, request_amendment: false, ssr_destroyed: false)
    # Iterates through each SSR to find the correct admin email.
    # Passes the correct SSR to display in the attachment and email.
    sub_service_requests.each do |sub_service_request|
      audit_report = request_amendment ? sub_service_request.audit_report(@current_user, sub_service_request.service_request.previous_submitted_at.utc, Time.now.utc) : nil
      sub_service_request.organization.submission_emails_lookup.each do |submission_email|
        service_list_false = sub_service_request.service_request.service_list(false, nil, sub_service_request)
        service_list_true = sub_service_request.service_request.service_list(true, nil, sub_service_request)
        line_items = sub_service_request.line_items
        protocol = @service_request.protocol
        controller = set_instance_variables(@current_user, @service_request, service_list_false, service_list_true, line_items, protocol)
        xls = controller.render_to_string action: 'show', formats: [:xlsx]
        Notifier.notify_admin(submission_email.email, xls, @current_user, sub_service_request, audit_report, ssr_destroyed).deliver
      end
    end
  end

  private
  def send_notifications(sub_service_requests)
    # If user has added a new service related to a new ssr and edited an existing ssr, 
    # we only want to send a request amendment email and not an initial submit email
    send_user_notifications(request_amendment: false) unless @send_request_amendment_and_not_initial
    send_admin_notifications(sub_service_requests, request_amendment: false) 
    send_service_provider_notifications(sub_service_requests, request_amendment: false) 
  end

  def send_user_notifications(request_amendment: false)
    # Does an approval need to be created?  Check that the user
    # submitting has approve rights.
    audit_report = authorized_user_audit_report
    service_list_false = @service_request.service_list(false)
    service_list_true = @service_request.service_list(true)
    line_items = @service_request.line_items
    protocol = @service_request.protocol

    controller = set_instance_variables(@current_user, @service_request, service_list_false, service_list_true, line_items, protocol)

    xls = controller.render_to_string action: 'show', formats: [:xlsx]

    if @service_request.protocol.project_roles.detect{|pr| pr.identity_id == @current_user.id}.project_rights != "approve"
      approval = @service_request.approvals.create
    else
      approval = false
    end

    # send e-mail to all folks with view and above
    @service_request.protocol.project_roles.each do |project_role|
      next if project_role.project_rights == 'none' || project_role.identity.email.blank?
      # Do not want to send authorized user request amendment emails when audit_report is not present
      if request_amendment && audit_report.present?
        Notifier.notify_user(project_role, @service_request, xls, approval, @current_user, audit_report).deliver_now
      elsif !request_amendment
        Notifier.notify_user(project_role, @service_request, xls, approval, @current_user, audit_report).deliver_now
      end
    end
  end

  def send_service_provider_notifications(sub_service_requests, request_amendment: false)
    sub_service_requests.each do |sub_service_request|
      send_ssr_service_provider_notifications(sub_service_request, ssr_destroyed: false, request_amendment: request_amendment)
    end
  end

  def send_individual_service_provider_notification(sub_service_request, service_provider, audit_report=nil, ssr_destroyed=false, request_amendment=false)
    attachments = {}
    service_list_true = @service_request.service_list(true, service_provider)
    service_list_false = @service_request.service_list(false, service_provider)

    # Retrieves the valid line items for service provider to calculate total direct cost in the xls
    line_items = []
    @service_request.sub_service_requests.each do |ssr|
      if service_provider.identity.is_service_provider?(ssr)
        line_items << ssr.line_items
      end
    end

    line_items = line_items.flatten
    protocol = @service_request.protocol
    controller = set_instance_variables(@current_user, @service_request, service_list_false, service_list_true, line_items, protocol)
    xls = controller.render_to_string action: 'show', formats: [:xlsx]
    attachments["service_request_#{sub_service_request.service_request.id}.xlsx"] = xls
    #TODO this is not very multi-institutional
    # generate the required forms pdf if it's required

    if sub_service_request.organization.tag_list.include? 'required forms'
      request_for_grant_billing_form = RequestGrantBillingPdf.generate_pdf service_request
      attachments["request_for_grant_billing_#{sub_service_request.service_request.id}.pdf"] = request_for_grant_billing_form
    end

    ssr_id = sub_service_request.id
    Notifier.notify_service_provider(service_provider, @service_request, attachments, @current_user, ssr_id, audit_report, ssr_destroyed, request_amendment).deliver_now
  end

  def ssr_has_changed?(sub_service_request) #specific ssr has changed?
    previously_submitted_at = @service_request.previous_submitted_at.nil? ? Time.now.utc : @service_request.previous_submitted_at.utc
    unless sub_service_request.audit_report(@current_user, previously_submitted_at, Time.now.utc)[:line_items].empty?
      return true
    end
    return false
  end

   def send_request_amendment(sub_service_requests)
    sub_service_requests = [sub_service_requests].flatten
    send_user_notifications(request_amendment: true)
    send_service_provider_notifications(sub_service_requests, request_amendment: true)
    send_admin_notifications(sub_service_requests, request_amendment: true)
  end

  def update_service_request_status(status, validate=true, submit=false)
    requests = []

    @service_request.sub_service_requests.each do |ssr|
      if UPDATABLE_STATUSES.include?(ssr.status) || !submit
        requests << ssr
      end
    end

    to_notify = @service_request.update_status(status, validate, submit)

    if (status == 'submitted')
      @service_request.previous_submitted_at = @service_request.submitted_at
      @service_request.update_attribute(:submitted_at, Time.now)
      requests.each { |ssr| ssr.update_attributes(submitted_at: Time.now) }
    end

    to_notify
  end

  def authorized_user_audit_report
    previously_submitted_at = @service_request.previous_submitted_at.nil? ? Time.now.utc : @service_request.previous_submitted_at.utc
    audit_report = @service_request.audit_report(@current_user, previously_submitted_at, Time.now.utc)
    audit_report = audit_report[:line_items].values.flatten
    filtered_audit_report = { :line_items => [] }
    audit_report.group_by{ |audit| audit[:audited_changes]['service_id'] }.each do |service_id, audits|
      service_actions_since_previous_submission = audits.sort_by(&:created_at).map(&:action)
      if service_actions_since_previous_submission.size >= 2 && service_actions_since_previous_submission.first == 'create' && service_actions_since_previous_submission.last == 'create'
        # EXAMPLE:  service_actions_since_previous_submission == ['create', 'destroy', 'create'] || service_actions_since_previous_submission == ["create", "destroy", "create", "destroy", "create"]
        # END RESULT:  DISPLAY THE LAST CREATED LINE ITEM
        filtered_audit_report[:line_items] << audits.last
      elsif service_actions_since_previous_submission.size >= 2 && service_actions_since_previous_submission.first == 'create' && service_actions_since_previous_submission.last == 'destroy'
        # EXAMPLE:  service_actions_since_previous_submission == ['create', 'destroy'] || service_actions_since_previous_submission == ['create', 'destroy', 'create', 'destroy']
        # END RESULT:  DO NOT DISPLAY EITHER LINE ITEM
      else
        audits.each do |audit|
          filtered_audit_report[:line_items] << audit
        end
      end
    end
    filtered_audit_report[:line_items].present? ? filtered_audit_report : nil
  end

  def set_instance_variables(current_user, service_request, service_list_false, service_list_true, line_items, protocol)
    controller = ServiceRequestsController.new()
    controller.instance_variable_set(:"@current_user", current_user)
    controller.instance_variable_set(:"@service_request", service_request)
    controller.instance_variable_set(:"@service_list_false", service_list_false)
    controller.instance_variable_set(:"@service_list_true", service_list_true)
    controller.instance_variable_set(:"@line_items", line_items)
    controller.instance_variable_set(:"@protocol", protocol)
    controller
  end
end