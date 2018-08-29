# Copyright © 2011-2018 MUSC Foundation for Research Development
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
class NotifierLogic

  def initialize(service_request, sub_service_request, current_user)
    @service_request = service_request
    @current_user = current_user
    @sub_service_request = sub_service_request
    @destroyed_ssrs_needing_notification = destroyed_ssr_that_needs_a_request_amendment_email
    @created_ssrs_needing_notification = @service_request.created_ssrs_since_previous_submission
    @ssrs_updated_from_un_updatable_status = ssrs_that_have_been_updated_from_a_un_updatable_status
  end

  def ssr_deletion_emails(deleted_ssr: nil, ssr_destroyed: true, request_amendment: false, admin_delete_ssr: false)
    if admin_delete_ssr
      send_user_notifications(request_amendment: false, admin_delete_ssr: true, deleted_ssr: deleted_ssr)
      send_ssr_service_provider_notifications(deleted_ssr, ssr_destroyed: true, request_amendment: false)
      send_admin_notifications([deleted_ssr], request_amendment: false, ssr_destroyed: true)
    elsif @ssrs_updated_from_un_updatable_status.present?
      send_ssr_service_provider_notifications(deleted_ssr, ssr_destroyed: true, request_amendment: false)
      send_admin_notifications([deleted_ssr], request_amendment: false, ssr_destroyed: true)
    end
  end

  def update_ssrs_and_send_emails
    # @to_notify holds the SSRs that require an "initial submission" email
    @send_request_amendment_and_not_initial = @ssrs_updated_from_un_updatable_status.present? || @destroyed_ssrs_needing_notification.present? || @created_ssrs_needing_notification.present?
    @to_notify = []
    if @sub_service_request
      @to_notify = @sub_service_request.update_status_and_notify('submitted')
    else
      @to_notify = @service_request.update_status('submitted')
      @service_request.previous_submitted_at = @service_request.submitted_at
      @service_request.update_attribute(:submitted_at, Time.now)
      @service_request.update_arm_minimum_counts
    end
    send_request_amendment_email_evaluation
    send_initial_submission_email
  end

  def update_status_and_send_get_a_cost_estimate_email
    to_notify = []
    if @sub_service_request
      to_notify = @sub_service_request.update_status_and_notify('get_a_cost_estimate')
      if to_notify.include?(@sub_service_request.id)
        send_user_notifications(request_amendment: false, admin_delete_ssr: false, deleted_ssr: nil)
        send_admin_notifications([@sub_service_request], request_amendment: false)
        send_service_provider_notifications([@sub_service_request], request_amendment: false)
      end
    else
      to_notify = @service_request.update_status('get_a_cost_estimate')
      sub_service_requests = @service_request.sub_service_requests.where(id: to_notify)
      if !sub_service_requests.empty? # if nothing is set to notify then we shouldn't send out e-mails
        send_user_notifications(request_amendment: false, admin_delete_ssr: false, deleted_ssr: nil)
        send_admin_notifications(sub_service_requests, request_amendment: false)
        send_service_provider_notifications(sub_service_requests, request_amendment: false)
      end
    end
  end

  def send_ssr_service_provider_notifications(sub_service_request, ssr_destroyed: false, request_amendment: false)
    audit_report = request_amendment ? sub_service_request.audit_line_items(@current_user) : nil
    sub_service_request.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)").each do |service_provider|
      send_individual_service_provider_notification(sub_service_request, service_provider, audit_report, ssr_destroyed, request_amendment)
    end
  end

  def send_admin_notifications(sub_service_requests, request_amendment: false, ssr_destroyed: false)
    # Iterates through each SSR to find the correct admin email.
    # Passes the correct SSR to display in the attachment and email.
    sub_service_requests.each do |sub_service_request|
      audit_report = request_amendment ? sub_service_request.audit_line_items(@current_user) : nil
      sub_service_request.organization.submission_emails_lookup.each do |submission_email|
        individual_ssr = @sub_service_request.present? ? true : false
        if ssr_destroyed
          Notifier.notify_admin(submission_email.email, @current_user, sub_service_request, audit_report, ssr_destroyed, individual_ssr).deliver_now
        else
          Notifier.delay.notify_admin(submission_email.email, @current_user, sub_service_request, audit_report, ssr_destroyed, individual_ssr)
        end
      end
    end
  end

  private

  def ssrs_that_have_been_updated_from_a_un_updatable_status
    draft_ssrs = find_draft_ssrs
    # Filtering out the newly created draft ssrs
    ssrs_that_have_been_updated_from_a_un_updatable_status = []
    draft_ssrs.each do |ssr|
      past_status = PastStatus.where(sub_service_request_id: ssr.id).last
      un_updatable_statuses = SubServiceRequest.all.map(&:status).uniq - Setting.get_value("updatable_statuses")
      if past_status.present?
        if un_updatable_statuses.include?(past_status.status)
          ssrs_that_have_been_updated_from_a_un_updatable_status << ssr
        end
      end
    end
    ssrs_that_have_been_updated_from_a_un_updatable_status
  end


  def send_initial_submission_email
    if @sub_service_request && @to_notify.include?(@sub_service_request.id)
      send_notifications([@sub_service_request])
    elsif !@to_notify.empty?
      sub_service_requests = @service_request.sub_service_requests.where(id: @to_notify)
      send_notifications(sub_service_requests) unless sub_service_requests.empty? # if nothing is set to notify then we shouldn't send out e-mails
    end
  end

  def send_request_amendment_email_evaluation
    if @ssrs_updated_from_un_updatable_status.present? || @destroyed_ssrs_needing_notification.present? || @created_ssrs_needing_notification.present?
      send_user_notifications(request_amendment: true, admin_delete_ssr: false, deleted_ssr: nil)
    end

    if @ssrs_updated_from_un_updatable_status.present?
      send_service_provider_notifications(@ssrs_updated_from_un_updatable_status, request_amendment: true)
      send_admin_notifications(@ssrs_updated_from_un_updatable_status, request_amendment: true)
    end
  end

  def send_notifications(sub_service_requests)
    # If user has added a new service related to a new ssr and edited an existing ssr,
    # we only want to send a request amendment email and not an initial submit email
    send_user_notifications(request_amendment: false, admin_delete_ssr: false, deleted_ssr: nil) unless @send_request_amendment_and_not_initial
    send_admin_notifications(sub_service_requests, request_amendment: false)
    send_service_provider_notifications(sub_service_requests, request_amendment: false)
  end

  def send_user_notifications(request_amendment: false, admin_delete_ssr: false, deleted_ssr: nil)
    # Does an approval need to be created?  Check that the user
    # submitting has approve rights.
    individual_ssr = @sub_service_request.present? ? true : false

    if request_amendment
      if individual_ssr
        audit_report = @sub_service_request.audit_line_items(@current_user)
      else
        audit_report = authorized_user_audit_report
      end
    else
      audit_report = nil
    end

    if @service_request.protocol.project_roles.where(identity: @current_user).where.not(project_rights: "approve").any?
      approval = @service_request.approvals.create
    else
      approval = false
    end
    
    deleted_ssrs = @service_request.deleted_ssrs_since_previous_submission(true)

    # send e-mail to all folks with view and above
    @service_request.protocol.project_roles.each do |project_role|
      next if project_role.project_rights == 'none' || project_role.identity.email.blank?
      if admin_delete_ssr # Users get an Deletion Email upon SSR deletion from Dashboard --> Admin Edit, otherwise deleted SSR is included in the Request Amendment Email
        Notifier.notify_user(project_role, @service_request, @sub_service_request, approval, @current_user, audit_report, individual_ssr, deleted_ssr, admin_delete_ssr).deliver
      elsif request_amendment && audit_report.present? # Request Amendment Email
        Notifier.delay.notify_user(project_role, @service_request, @sub_service_request, approval, @current_user, audit_report, individual_ssr, deleted_ssrs, admin_delete_ssr)
      elsif !request_amendment # Initial Submission Email
        Notifier.delay.notify_user(project_role, @service_request, @sub_service_request, approval, @current_user, audit_report, individual_ssr, nil, admin_delete_ssr)
      end
    end
  end

  def send_service_provider_notifications(sub_service_requests, request_amendment: false)
    sub_service_requests.each do |sub_service_request|
      send_ssr_service_provider_notifications(sub_service_request, ssr_destroyed: false, request_amendment: request_amendment)
    end
  end

  def send_individual_service_provider_notification(sub_service_request, service_provider, audit_report=nil, ssr_destroyed=false, request_amendment=false)
    individual_ssr = @sub_service_request.present? ? true : false
    if ssr_destroyed
      Notifier.notify_service_provider(service_provider, @service_request, @current_user, sub_service_request, audit_report, ssr_destroyed, request_amendment, individual_ssr).deliver_now
    else
      Notifier.delay.notify_service_provider(service_provider, @service_request, @current_user, sub_service_request, audit_report, ssr_destroyed, request_amendment, individual_ssr)
    end
  end

  def filter_audit_trail(identity, ssr_ids_that_need_auditing)
    filtered_audit_trail = {:line_items => []}
    ssr_ids_that_need_auditing.each do |ssr_id|
      ssr_line_item_audit = SubServiceRequest.find(ssr_id).audit_line_items(identity)
      if !ssr_line_item_audit.nil?
        filtered_audit_trail[:line_items] << ssr_line_item_audit[:line_items]
      end
    end
    filtered_audit_trail[:line_items].flatten
  end

  def authorized_user_audit_report

    added_ssrs_ids = @created_ssrs_needing_notification.map(&:auditable_id)

    destroyed_ssrs_ids = @service_request.deleted_ssrs_since_previous_submission(true).map(&:auditable_id)

    created_and_destroyed_ssrs = added_ssrs_ids & destroyed_ssrs_ids

    destroyed_ssrs_ids = destroyed_ssrs_ids - created_and_destroyed_ssrs
    ssr_ids_that_need_auditing = [@ssrs_updated_from_un_updatable_status.map(&:id), added_ssrs_ids].flatten
    ssr_ids_that_need_auditing = ssr_ids_that_need_auditing - created_and_destroyed_ssrs

    destroyed_lis = []
    destroyed_ssrs_ids.each do |id|
      destroyed_lis << AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{id}%' AND auditable_type = 'LineItem' AND user_id = #{@current_user.id} AND action IN ('destroy') AND created_at BETWEEN '#{@service_request.previous_submitted_at.utc}' AND '#{Time.now.utc}'")
    end

    audit_report = filter_audit_trail(@current_user, ssr_ids_that_need_auditing)
    audit_report = [audit_report, destroyed_lis].flatten
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

  def destroyed_ssr_that_needs_a_request_amendment_email
    deleted_ssr_audits_that_need_request_amendment_email = []
    destroyed_ssr_audit = @service_request.deleted_ssrs_since_previous_submission

    destroyed_ssr_audit.each do |ssr_audit|
      un_updatable_statuses = SubServiceRequest.all.map(&:status).uniq - Setting.get_value("updatable_statuses")
      latest_action_update_audit = AuditRecovery.where("auditable_id = #{ssr_audit.auditable_id} AND action = 'update'")
      latest_action_update_audit = latest_action_update_audit.present? ? latest_action_update_audit.order(created_at: :desc).first : nil
      if latest_action_update_audit.nil? || latest_action_update_audit.audited_changes['status'].nil?
        latest_action_destroy_audit = AuditRecovery.where("auditable_id = #{ssr_audit.auditable_id} AND action = 'destroy'")
        latest_action_destroy_audit = latest_action_destroy_audit.present? ? latest_action_destroy_audit.order(created_at: :desc).first : nil
        if latest_action_destroy_audit.present? && un_updatable_statuses.include?(latest_action_destroy_audit.audited_changes['status'])
          deleted_ssr_audits_that_need_request_amendment_email << ssr_audit
        end
      else
        if un_updatable_statuses.include?(latest_action_update_audit.audited_changes['status'].first)
          deleted_ssr_audits_that_need_request_amendment_email << ssr_audit
        end
      end
    end
    deleted_ssr_audits_that_need_request_amendment_email
  end

  def find_draft_ssrs
    if @sub_service_request
      ssrs_with_draft_status = @sub_service_request.status == 'draft' ? [@sub_service_request] : []
    else
      ssrs_with_draft_status = @service_request.sub_service_requests.select{ |ssr| (ssr.status == "draft") }
    end
    ssrs_with_draft_status
  end
end
