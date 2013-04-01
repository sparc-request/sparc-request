class UserMailer < ActionMailer::Base
  default :from => "no-reply@musc.edu"

  def authorized_user_changed(user, protocol)
    @send_to = user
    @protocol = protocol

    send_message('SPARC Authorized Users')
  end

  def notification_received(user)
    @send_to = user

    send_message('New SPARC Notification')
  end

  private

  def send_message subject
    email = Rails.env == 'production' ? @send_to.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? subject : "[#{Rails.env.capitalize} - EMAIL TO #{@send_to.email}] #{subject}"

    mail(:to => email, :subject => subject)
  end

end
