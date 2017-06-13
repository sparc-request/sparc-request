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


class Notifier < ActionMailer::Base
  helper ApplicationHelper

  def new_identity_waiting_for_approval identity
    @identity = identity

    email = ADMIN_MAIL_TO
    cc = NEW_USER_CC

    ##REVIEW: This subject appears incorrect? Copy paste from previous method?
    subject = "New Question from #{t(:mailer)[:application_title]}"

    mail(:to => email, :cc => cc, :from => @identity.email, :subject => subject)
  end

  def notify_user(project_role, service_request, ssr, approval, user_current, audit_report=nil, individual_ssr=false)

    @protocol = service_request.protocol
    @service_request = service_request

    ### ATTACHMENTS ###
    service_list_false = @service_request.service_list(false)
    service_list_true = @service_request.service_list(true)
    controller = set_instance_variables(user_current, @service_request, service_list_false, service_list_true, @service_request.line_items, @protocol)

    xls = controller.render_to_string action: 'show', formats: [:xlsx]
    ### END ATTACHMENTS ###
    
    if audit_report.present?
      @status = 'request_amendment'
    elsif individual_ssr
      @status = ssr.status
    else
      @status = @service_request.status
    end

    @notes = []
    @identity = project_role.identity
    @role = project_role.role
    @full_name = @identity.full_name
    @audit_report = audit_report

    @service_requester_id = @service_request.sub_service_requests.first.service_requester_id

    @portal_link = DASHBOARD_LINK + "/protocols/#{@protocol.id}"
    @ssrs_to_be_displayed =  individual_ssr ? [ssr] : @service_request.sub_service_requests

    attachments["service_request_#{@protocol.id}.xlsx"] = xls

    # only send these to the correct person in the production env
    email = @identity.email
    subject = "#{@protocol.id} - #{t(:mailer)[:application_title]} service request"

    mail(:to => email, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_admin(submission_email_address, user_current, ssr, audit_report=nil, ssr_destroyed=false, individual_ssr=false)

    @protocol = ssr.protocol
    @service_request = ssr.service_request

    ### ATTACHMENTS ###
    service_list_false = @service_request.service_list(false, nil, ssr)
    service_list_true = @service_request.service_list(true, nil, ssr)
    controller = set_instance_variables(user_current, @service_request, service_list_false, service_list_true, ssr.line_items, @protocol)
    xls = controller.render_to_string action: 'show', formats: [:xlsx]
    ### END ATTACHMENTS ###

    @ssr_deleted = false
    @notes = @protocol.notes

    @status = status(ssr_destroyed, audit_report.present?, individual_ssr, ssr, @service_request)

    @role = 'none'
    @full_name = submission_email_address

    @service_requester_id = @service_request.sub_service_requests.first.service_requester_id
    @ssrs_to_be_displayed = [ssr]

    @portal_link = DASHBOARD_LINK + "/protocols/#{@protocol.id}"
    @portal_text = "Administrators/Service Providers, Click Here"

    @audit_report = audit_report

    if !ssr_destroyed
      attachments["service_request_#{@protocol.id}.xlsx"] = xls
    end

    email =  submission_email_address
    subject = "#{@protocol.id} - #{t(:mailer)[:application_title]} service request"

    mail(:to => email, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_service_provider(service_provider, service_request, user_current, ssr, audit_report=nil, ssr_destroyed=false, request_amendment=false, individual_ssr=false)
    @protocol = service_request.protocol
    @service_request = service_request
    @notes = @protocol.notes

    @status = status(ssr_destroyed, request_amendment, individual_ssr, ssr, @service_request)
    
    @role = 'none'
    @full_name = service_provider.identity.full_name

    @service_requester_id = @service_request.sub_service_requests.first.service_requester_id

    @audit_report = audit_report

    @portal_link = DASHBOARD_LINK + "/protocols/#{@protocol.id}"
    @portal_text = "Administrators/Service Providers, Click Here"

    ### ATTACHMENTS ###
    attachments_to_add = {}
    service_list_true = @service_request.service_list(true, service_provider)
    service_list_false = @service_request.service_list(false, service_provider)

    # Retrieves the valid line items for service provider to calculate total direct cost in the xls
    line_items = []
    @service_request.sub_service_requests.each do |sub_service_request|
      if service_provider.identity.is_service_provider?(sub_service_request)
        line_items << sub_service_request.line_items
      end
    end

    line_items = line_items.flatten
    controller = set_instance_variables(user_current, @service_request, service_list_false, service_list_true, line_items, @protocol)

    xls = controller.render_to_string action: 'show', formats: [:xlsx]
    attachments_to_add["service_request_#{@service_request.id}.xlsx"] = xls
    #TODO this is not very multi-institutional
    # generate the required forms pdf if it's required

    if ssr.organization.tag_list.include? 'required forms'
      request_for_grant_billing_form = RequestGrantBillingPdf.generate_pdf @service_request
      attachments_to_add["request_for_grant_billing_#{@service_request.id}.pdf"] = request_for_grant_billing_form
    end
    ### END ATTACHMENTS ###

    # only display the ssrs that are associated with service_provider
    @ssrs_to_be_displayed = [ssr] if service_provider.identity.is_service_provider?(ssr)

    if !ssr_destroyed
      attachments_to_add.each do |file_name, document|
        next if document.nil?
        attachments["#{file_name}"] = document
      end
    end

    # only send these to the correct person in the production env
    email = service_provider.identity.email
    subject = "#{@protocol.id} - #{t(:mailer)[:application_title]} service request"

    mail(:to => email, :from => NO_REPLY_FROM, :subject => subject)
  end

  def account_status_change identity, approved
    @approved = approved

    ##REVIEW: Why do we care what the from is?
    email_from = Rails.env == 'production' ? ADMIN_MAIL_TO : DEFAULT_MAIL_TO
    email_to = identity.email
    subject = "#{t(:mailer)[:application_title]} account request - status change"

    mail(:to => email_to, :from => email_from, :subject => subject)
  end

  def obtain_research_pricing service_provider, service_request

  end

  def provide_feedback feedback
    @feedback = feedback

    email_to = FEEDBACK_MAIL_TO
    email_from = @feedback.email.blank? ? DEFAULT_MAIL_TO : @feedback.email

    mail(:to => email_to, :from => email_from, :subject => "Feedback")
  end

  def sub_service_request_deleted identity, sub_service_request, user_current
    @ssr_id = "#{sub_service_request.protocol.id}-#{sub_service_request.ssr_id}"

    @triggered_by = user_current.id
    @service_request = sub_service_request.service_request
    @ssr = sub_service_request

    email_to = identity.email
    subject = "#{sub_service_request.protocol.id} - #{t(:mailer)[:application_title]} - service request deleted"

    mail(:to => email_to, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_for_epic_user_approval protocol
    @protocol = protocol
    @primary_pi = @protocol.primary_principal_investigator

    subject = "#{@protocol.id} - Epic Rights Approval"

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_primary_pi_for_epic_user_final_review protocol
    @protocol = protocol
    @primary_pi = @protocol.primary_principal_investigator

    email_to = @primary_pi.email
    subject = "#{@protocol.id} - Epic Rights User Approval"

    mail(:to => email_to, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_primary_pi_for_epic_user_removal protocol, project_role
    @protocol = protocol
    @primary_pi = @protocol.primary_principal_investigator
    @project_role = project_role

    subject = "#{@protocol.id} - Epic User Removal"

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_for_epic_access_removal protocol, project_role
    @protocol = protocol
    @project_role = project_role

    subject = "#{@protocol.id} - Remove Epic Access"

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_for_epic_rights_changes protocol, project_role, previous_rights
    @protocol = protocol
    @project_role = project_role
    @added_rights = project_role.epic_rights - previous_rights
    @removed_rights = previous_rights - project_role.epic_rights

    subject = "#{@protocol.id} - Update Epic Access"

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def epic_queue_error protocol, error=nil
    @protocol = protocol
    @error = error
    mail(:to => QUEUE_EPIC_LOAD_ERROR_TO, :from => NO_REPLY_FROM, :subject => "#{@protocol.id} - Error batch loading protocol to Epic")
  end

  def epic_queue_report
    attachments["epic_queue_report.csv"] = File.read(Rails.root.join("tmp", "epic_queue_report.csv"))
    mail(:to => EPIC_QUEUE_REPORT_TO, :from => NO_REPLY_FROM, :subject => "Epic Queue Report")
  end

  def epic_queue_complete sent, failed
    @sent = sent
    @failed = failed
    mail(:to => EPIC_QUEUE_REPORT_TO, :from => NO_REPLY_FROM, :subject => "Epic Queue Complete")
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

  def status(ssr_destroyed, request_amendment, individual_ssr, ssr, service_request)
    if ssr_destroyed
      status = 'ssr_destroyed'
    elsif request_amendment
      status = 'request_amendment'
    elsif individual_ssr
      status = ssr.status
    else
      status = service_request.status
    end
    status
  end
end
