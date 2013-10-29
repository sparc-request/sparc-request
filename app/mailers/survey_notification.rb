class SurveyNotification < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  
  def system_satisfaction_survey response_set
    @response_set = response_set 
    @identity = Identity.find response_set.user_id
    
    email = Rails.env == 'production' ? ADMIN_MAIL_TO : DEFAULT_MAIL_TO
    cc = Rails.env == 'production' ? SYSTEM_SATISFACTION_SURVEY_CC : nil
    subject = Rails.env == 'production' ? "System satisfaction survey completed in #{I18n.t('application_title')}" : "[#{Rails.env.capitalize} - EMAIL TO #{ADMIN_MAIL_TO} AND CC TO #{SYSTEM_SATISFACTION_SURVEY_CC}] System satisfaction survey completed in #{I18n.t('application_title')}"
    
    mail(:to => email, :cc => cc, :from => @identity.email, :subject => subject) 
  end
  
  def service_survey surveys, identity, ssr
    @identity = identity
    @surveys = surveys
    @ssr = ssr
    email = Rails.env == 'production' ? @identity.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "#{I18n.t('application_title')} Survey Notification" : "[#{Rails.env.capitalize} - EMAIL TO #{ADMIN_MAIL_TO} AND CC TO #{SYSTEM_SATISFACTION_SURVEY_CC}] #{I18n.t('application_title')} Survey Notification"
    mail(:to => email, :from => 'no-reply@musc.edu', :subject => subject) 
  end

end
