class SurveyNotification < ActionMailer::Base
  
  def system_satisfaction_survey response_set
    @response_set = response_set 
    @identity = Identity.find response_set.user_id
    
    email = Rails.env == 'production' ? ADMIN_MAIL_TO : DEFAULT_MAIL_TO
    cc = Rails.env == 'production' ? SYSTEM_SATISFACTION_SURVEY_CC : nil
    subject = Rails.env == 'production' ? "System satisfaction survey completed in #{I18n.t('application_title')}" : "[#{Rails.env.capitalize} - EMAIL TO #{ADMIN_MAIL_TO} AND CC TO #{SYSTEM_SATISFACTION_SURVEY_CC}] System satisfaction survey completed in #{I18n.t('application_title')}"
    
    mail(:to => email, :cc => cc, :from => @identity.email, :subject => subject) 
  end
  
  def service_satisfaction_survey surveys, identity
    @identity = identity
    @surveys = surveys
    email = Rails.env == 'production' ? @identity.email : DEFAULT_MAIL_TO
    subject = Rails.env == 'production' ? "Service satisfaction survey for #{I18n.t('application_title')}" : "[#{Rails.env.capitalize} - EMAIL TO #{ADMIN_MAIL_TO} AND CC TO #{SYSTEM_SATISFACTION_SURVEY_CC}] Service satisfaction survey for #{I18n.t('application_title')}"
    mail(:to => email, :from => 'no-reply@musc.edu', :subject => subject) 
  end

end
