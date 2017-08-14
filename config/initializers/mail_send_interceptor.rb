class MailSendInterceptor

  class << self
    def delivering_email(mail)
      cc_to = " AND CC TO #{mail.cc}" if mail.cc.present?

      mail.subject = "[#{Setting.find_by_key("host").value} - EMAIL TO #{mail.to} #{cc_to}] #{mail.subject}"
      mail.to = Setting.find_by_key("default_mail_to").value
      mail.cc = nil
    end
  end
end

# This initializer depends on obis_setup having been run first in order to read in application config values
if Setting.find_by_key("send_emails_to_real_users") != true
  ActionMailer::Base.register_interceptor(MailSendInterceptor)
end
