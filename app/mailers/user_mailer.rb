class UserMailer < ActionMailer::Base
  default :from => "no-reply@musc.edu"

  def authorized_user_changed(user, protocol)
    @user = user
    @protocol = protocol

    send_message()
    
  end

  def notification_received(user)
    @user = user

    send_message()
  end

  private

  def send_message
    case Rails.env
    when 'development'
      @portal_host = "localhost:3000"
      mail(:to => 'scoma@musc.edu', :subject => "SPARC Authorized Users")
    when 'staging'
      @portal_host = "sparc-stg.musc.edu/user_portal"
      mail(:to => 'glennj@musc.edu', :subject => "SPARC Authorized Users")
    when 'testing'
      @portal_host = "sparc-test.musc.edu/portal"
      mail(:to => 'glennj@musc.edu', :subject => "SPARC Authorized Users")
    when 'training'
      @portal_host = "sparc-trn.musc.edu/portal"
      mail(:to => 'glennj@musc.edu', :subject => "SPARC Authorized Users")
    else
      @portal_host = "sparc.musc.edu/portal"
      mail(:to => @user.email, :subject => "SPARC Authorized Users")
    end
  end

end
