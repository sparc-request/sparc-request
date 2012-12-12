class Notifier < ActionMailer::Base
  def ask_a_question question
    @question = question
    mail(:to => @question.to, :from => @question.from, :subject => 'New Question from SPARC')
  end

  def new_identity_waiting_for_approval identity
    @identity = identity
    mail(:to => "catesa@musc.edu", :from => "no-reply@musc.edu", :subject => "A New Identity is Waiting for Approval")
  end

  def notify_user identity, service_request
    @identity = identity
    @protocol = service_request.protocol
    @role = @protocol.project_roles.detect{|pr| pr.identity_id = identity.id}.role
    @service_request = service_request
    attachments["service_request_#{@service_request.id}.xls"] = render xlsx: "show", filename: "service_request_#{@service_request.id}", disposition: "inline"
    mail(:to => identity.email, :from => "no-reply@musc.edu", :subject => "SPARC Service Request")
  end
end
