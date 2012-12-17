class Notifier < ActionMailer::Base
  def ask_a_question question
    @question = question
    mail(:to => DEFAULT_MAIL_TO, :from => @question.from, :subject => 'New Question from SPARC')
  end

  def new_identity_waiting_for_approval identity
    @identity = identity
    mail(:to => DEFAULT_MAIL_TO, :from => @identity.email, :subject => "Request for new SPARC account submitted and awaiting approval") 
  end

  def notify_user identity, service_request, sub_service_request
    @identity = identity
    @protocol = service_request.protocol
    @role = @protocol.project_roles.detect{|pr| pr.identity_id = identity.id}.role
    @service_request = service_request
    @sub_service_request = sub_service_request
    attachments["service_request_#{@service_request.id}.xls"] = render xlsx: "show", filename: "service_request_#{@service_request.id}", disposition: "inline"
    mail(:to => identity.email, :from => "no-reply@musc.edu", :subject => "SPARC Service Request")
  end

  def account_status_change identity, approved
    @approved = approved
    mail(:to => identity.email, :from => DEFAULT_MAIL_TO, :subject => "SPARC account request - status change")
  end
end
