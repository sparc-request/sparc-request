class Notifier < ActionMailer::Base
  def ask_a_question question
    @question = question
    mail(:to => ADMIN_MAIL_TO, :from => @question.from, :subject => 'New Question from SPARC')
  end

  def new_identity_waiting_for_approval identity
    @identity = identity
    mail(:to => DEFAULT_MAIL_TO, :from => @identity.email, :subject => "Request for new SPARC account submitted and awaiting approval") 
  end

  def notify_user identity, role, service_request, sub_service_request, xls
    @identity = identity
    @protocol = service_request.protocol
    @role = role 
    @service_request = service_request
    @sub_service_request = sub_service_request
    
    attachments["service_request_#{@service_request.id}.xls"] = xls 
    
    # only truely send these e-mails in the production env
    email = Rails.env == 'production' ? identity.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "SPARC Service Request" : "[#{Rails.env.capitalize} - EMAIL TO #{identity.email}] SPAR Service Request"
    
    mail(:to => email, :from => "no-reply@musc.edu", :subject => subject)
  end

  def account_status_change identity, approved
    @approved = approved
    mail(:to => identity.email, :from => DEFAULT_MAIL_TO, :subject => "SPARC account request - status change")
  end
end
