# Copyright © 2011 MUSC Foundation for Research Development
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

  def ask_a_question quick_question
    @quick_question = quick_question

    # TODO: this process needs to be moved to a helper method
    # it's repeated in each action with slightly different information
    email = Rails.env == 'production' ? ADMIN_MAIL_TO : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "New Question from #{I18n.t('application_title')}" : "[#{Rails.env.capitalize} - EMAIL TO #{ADMIN_MAIL_TO}] New Question from #{I18n.t('application_title')}"

    mail(:to => email, :from => @quick_question.from, :subject => subject)
  end

  def new_identity_waiting_for_approval identity
    @identity = identity

    email = Rails.env == 'production' ? ADMIN_MAIL_TO : DEFAULT_MAIL_TO
    cc = Rails.env == 'production' ? NEW_USER_CC : nil
    subject = Rails.env == 'production' ? "New Question from #{I18n.t('application_title')}" : "[#{Rails.env.capitalize} - EMAIL TO #{ADMIN_MAIL_TO} AND CC TO #{NEW_USER_CC}] Request for new #{I18n.t('application_title')} account submitted and awaiting approval"

    mail(:to => email, :cc => cc, :from => @identity.email, :subject => subject)
  end

  def notify_user(project_role, service_request, xls, approval, user_current)
    @identity = project_role.identity
    @role = project_role.role

    @approval_link = nil
    if approval and project_role.project_rights == 'approve'
      @approval_link = approve_changes_service_request_url(service_request, :approval_id => approval.id)
    end

    @protocol = service_request.protocol
    @service_request = service_request
    @portal_link = DASHBOARD_LINK + "?default_protocol=#{@protocol.id}"
    @portal_text = "To VIEW and/or MAKE any changes to this request, please click here."
    @provide_arm_info = false

    @triggered_by = user_current.id
    @ssr_ids = service_request.sub_service_requests.map{ |ssr| ssr.id }.join(", ")

    attachments["service_request_#{@service_request.protocol.id}.xlsx"] = xls

    # only send these to the correct person in the production env
    email = Rails.env == 'production' ? @identity.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "#{I18n.t('application_title')} service request" : "[#{Rails.env.capitalize} - EMAIL TO #{@identity.email}] #{I18n.t('application_title')} service request"

    mail(:to => email, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_admin(service_request, submission_email_address, xls, user_current)
    @protocol = service_request.protocol
    @service_request = service_request
    @role = 'none'
    @approval_link = nil
    @portal_link = DASHBOARD_LINK
    @portal_text = "Administrators/Service Providers, Click Here"
    @provide_arm_info = false

    @triggered_by = user_current.id
    @ssr_ids = service_request.sub_service_requests.map{ |ssr| ssr.id }.join(", ")

    attachments["service_request_#{@service_request.protocol.id}.xlsx"] = xls

    # only send these to the correct person in the production env
    email = Rails.env == 'production' ?  submission_email_address : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "#{I18n.t('application_title')} service request" : "[#{Rails.env.capitalize} - EMAIL TO #{submission_email_address}] #{I18n.t('application_title')} service request"

    mail(:to => email, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_service_provider service_provider, service_request, attachments_to_add, user_current, audit_report=nil, ssr_deleted=false
    @protocol = service_request.protocol
    @service_request = service_request
    @role = 'none'
    @approval_link = nil
    @audit_report = audit_report
    @provide_arm_info = audit_report.nil? ? true : SubServiceRequest.find(@audit_report[:sub_service_request_id]).has_per_patient_per_visit_services?
    @ssr_deleted = ssr_deleted

    @portal_link = DASHBOARD_LINK
    @portal_text = "Administrators/Service Providers, Click Here"

    @triggered_by = user_current.id
    @ssr_ids = service_request.sub_service_requests.map{ |ssr| ssr.id }.join(", ")

    attachments_to_add.each do |file_name, document|
      next if document.nil?
      attachments["#{file_name}"] = document
    end

    # only send these to the correct person in the production env
    email = Rails.env == 'production' ? service_provider.identity.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "#{@protocol.id} - #{I18n.t('application_title')} service request" : "#{@protocol.id} - [#{Rails.env.capitalize} - EMAIL TO #{service_provider.identity.email}] #{I18n.t('application_title')} service request"

    mail(:to => email, :from => NO_REPLY_FROM, :subject => subject)
  end

  def account_status_change identity, approved
    @approved = approved

    email_from = Rails.env == 'production' ? ADMIN_MAIL_TO : DEFAULT_MAIL_TO
    email_to = Rails.env == 'production' ? identity.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "#{I18n.t('application_title')} account request - status change" : "[#{Rails.env.capitalize} - EMAIL TO #{identity.email}] #{I18n.t('application_title')} account request - status change"

    mail(:to => email_to, :from => email_from, :subject => subject)
  end

  def obtain_research_pricing service_provider, service_request

  end

  def provide_feedback feedback
    @feedback = feedback

    email_to = Rails.env == 'production' ? FEEDBACK_MAIL_TO : DEFAULT_MAIL_TO
    email_from = @feedback.email.blank? ? DEFAULT_MAIL_TO : @feedback.email

    mail(:to => email_to, :from => email_from, :subject => "Feedback")
  end

  def sub_service_request_deleted identity, sub_service_request, user_current
    @ssr_id = "#{sub_service_request.service_request.protocol.id}-#{sub_service_request.ssr_id}"

    @triggered_by = user_current.id
    @service_request = sub_service_request.service_request
    @ssr = sub_service_request

    email_to = Rails.env == 'production' ? identity.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "#{I18n.t('application_title')} - service request deleted" : "[#{Rails.env.capitalize} - EMAIL TO #{identity.email}] #{I18n.t('application_title')} - service request deleted"

    mail(:to => email_to, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_for_epic_user_approval protocol
    @protocol = protocol
    @primary_pi = @protocol.primary_principal_investigator

    subject = 'Epic Rights Approval'

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_primary_pi_for_epic_user_final_review protocol
    @protocol = protocol
    @primary_pi = @protocol.primary_principal_investigator

    email_to = Rails.env == 'production' ? @primary_pi.email : DEFAULT_MAIL_TO
    subject = 'Epic Rights User Approval'

    mail(:to => email_to, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_primary_pi_for_epic_user_removal protocol, project_role
    @protocol = protocol
    @primary_pi = @protocol.primary_principal_investigator
    @project_role = project_role

    subject = 'Epic User Removal'

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_for_epic_access_removal protocol, project_role
    @protocol = protocol
    @project_role = project_role

    subject = 'Remove Epic Access'

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def notify_for_epic_rights_changes protocol, project_role, previous_rights
    @protocol = protocol
    @project_role = project_role
    @added_rights = project_role.epic_rights - previous_rights
    @removed_rights = previous_rights - project_role.epic_rights

    subject = 'Update Epic Access'

    mail(:to => EPIC_RIGHTS_MAIL_TO, :from => NO_REPLY_FROM, :subject => subject)
  end

  def epic_queue_error protocol, error=nil
    @protocol = protocol
    @error = error
    mail(:to => QUEUE_EPIC_LOAD_ERROR_TO, :from => NO_REPLY_FROM, :subject => "Error batch loading protocol to Epic")
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

end
