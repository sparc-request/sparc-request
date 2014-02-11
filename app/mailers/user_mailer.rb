class UserMailer < ActionMailer::Base
  default :from => "donotreply@musc.edu"

  def authorized_user_changed(user, protocol)
    @send_to = user
    @protocol = protocol

    send_message("#{I18n.t('application_title')} Authorized Users")
  end

  def notification_received(user)
    @send_to = user

    send_message("New #{I18n.t('application_title')} Notification")
  end

  # Disabled (potentially only temporary) as per Lane
  # def subject_procedure_notification(user, procedure, ssr)
  #   @send_to = user
  #   @procedure = procedure
  #   @sub_service_request = ssr

  #   send_message("New #{I18n.t('application_title')} Individual Subject Procedure Notification")
  # end

  private

  def send_message subject
    email = Rails.env == 'production' ? @send_to.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? subject : "[#{Rails.env.capitalize} - EMAIL TO #{@send_to.email}] #{subject}"

    mail(:to => email, :subject => subject)
  end

end
