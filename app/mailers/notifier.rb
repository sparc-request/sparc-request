class Notifier < ActionMailer::Base
  def ask_a_question question
    @question = question
    mail(:to => @question.to, :from => @question.from, :subject => 'New Question from SPARC')
  end

  def new_identity_waiting_for_approval identity
    @identity = identity
    mail(:to => "catesa@musc.edu", :from => "no-reply@musc.edu", :subject => "A New Identity is Waiting for Approval")
  end

  def notify_user identity, protocol
    @identity = identity
    @role = protocol.project_roles.detect{|pr| pr.identity_id = identity.id}.role
    @protocol = protocol
    mail(:to => identity.email, :from => "no-reply@musc.edu", :subject => "SPARC Service Request")
  end
end
