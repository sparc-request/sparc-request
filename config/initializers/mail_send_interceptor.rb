class MailSendInterceptor

  class << self
    def delivering_email(mail)
      cc_to = " AND CC TO #{mail.cc}" if mail.cc.present?

      mail.subject = "[#{HOST} - EMAIL TO #{mail.to} #{cc_to}] #{mail.subject}"
      mail.to = DEFAULT_MAIL_TO
      mail.cc = nil
    end
  end
end

# This initializer depends on obis_setup having been run first in order to read in application config values
if SEND_EMAILS_TO_REAL_USERS != true
  ActionMailer::Base.register_interceptor(MailSendInterceptor)
end
