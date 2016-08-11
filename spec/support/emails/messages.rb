module EmailHelpers
  # Email messages based on the action (status:  submitted, get_a_cost_estimate, ***more to come)

  #### SUBMITTED MESSAGE METHODS ####
  def submitted_service_provider_and_admin_message
    # Expected message:  
    # 'A request has been submitted to start services in 
    # SPARCRequest and is awaiting your review in SPARCDashboard.'
    expect(mail).to have_xpath("//p[normalize-space(text()) = 'A request has been submitted to start services in SPARCRequest and is awaiting your review in']")
    expect(mail).to have_xpath "//p//a[@href='/dashboard/protocols/#{service_request.protocol.id}'][text()= 'SPARCDashboard.']/@href"
  end

  def submitted_general_users_message
    # Expected user message:  
    # "A request has been submitted to start services in 
    # SPARCRequest. Visit SPARCDashboard to view the status or 
    # make any updates to your request."
    expect(mail.body.parts.first.body).to have_xpath("//p[normalize-space(text()) = 'A request has been submitted to start services in SPARCRequest. Visit']")
    expect(mail.body.parts.first.body).to have_xpath "//p//a[@href='/dashboard/protocols/#{service_request.protocol.id}'][text()= 'SPARCDashboard']/@href"
    expect(mail.body.parts.first.body).to have_xpath("//p[normalize-space(text()) = 'to view the status or make any updates to your request.']")
  end
  #### END SUBMITTED MESSAGE METHODS ####

  #### GET A COST ESTIMATE MESSAGE METHODS ####
  def get_a_cost_estimate_service_provider_admin_message(mail_response)
    # Expected message:  
    # "A request has been made for a budget review (Get Cost Estimate) in 
    # SPARCRequest and is awaiting your review in SPARCDashboard. Please ensure services chosen 
    # are appropriate and can be provided. Communicate any necessary changes to the study team 
    # and request they “Submit to Start Services” once ready to proceed."
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = 'A request has been made for a budget review (Get Cost Estimate) in SPARCRequest and is awaiting your review in']")
    expect(mail_response).to have_xpath "//a[@href='/dashboard/protocols/#{service_request.protocol.id}'][text()= 'SPARCDashboard']/@href"
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = '. Please ensure services chosen are appropriate and can be provided. Communicate any necessary changes to the study team and request they “Submit to Start Services” once ready to proceed.']")
  end

  def get_a_cost_estimate_general_users
    # Expected message:
    # 'A request has been made for a budget review (Get Cost Estimate) in 
    # SPARCRequest. You can review or edit this request in SPARCDashboard. 
    # An email has been sent to the service provider(s) to review and ensure 
    # the services are appropriate. Please note the services will not start 
    # until this request is submitted through SPARCDashboard.'
    expect(mail.body.parts.first.body).to have_xpath("//p[normalize-space(text()) = 'A request has been made for a budget review (Get Cost Estimate) in SPARCRequest. You can review or edit this request in']")
    expect(mail.body.parts.first.body).to have_xpath "//a[@href='/dashboard/protocols/#{service_request.protocol.id}'][text()= 'SPARCDashboard']/@href"
    expect(mail.body.parts.first.body).to have_xpath("//p[normalize-space(text()) = '. An email has been sent to the service provider(s) to review and ensure the services are appropriate.']")
    expect(mail.body.parts.first.body).to have_xpath("//strong[normalize-space(text()) = 'Please note the services will not start until this request is submitted through SPARCDashboard.']")
  end
  #### END GET A COST ESTIMATE MESSAGE METHODS ####


  #### REUSABLE METHODS ####
  def service_provider_and_admin_link(mail_response)
    expect(mail_response).to have_xpath "//p//a[@href='/dashboard/protocols/#{service_request.protocol.id}'][text()= 'Administrators/Service Providers, Click Here']/@href"
  end

  def message_conclusion(mail_response)
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = 'A list of requested services is attached.']")
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = 'Please contact the SUCCESS Center at (843) 792-8300 or success@musc.edu for assistance with this process or with any questions you may have.']")
  end

  def does_have_acknowledgments
    service_request.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
      expect(mail.body.parts.first.body).to have_xpath("//p[normalize-space(text()) = '#{ack}']")
    end
  end

  def does_not_have_acknowledgments(mail_response)
    service_request.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
      expect(mail_response).not_to have_xpath("//p[normalize-space(text()) = '#{ack}']")
    end
  end
  #### END REUSABLE METHODS ####


  #### SUBMITTED ####
  def submitted_intro_for_service_providers_and_admin(mail_response)
    # Should have expected service provider message which is defined under submitted_service_provider_and_admin_message
    # Should have 'Administrators/Service Providers, Click Here' link
    # Should have standard message conclusion
    # Should NOT show acknowledgments 
    submitted_service_provider_and_admin_message
    service_provider_and_admin_link(mail_response)
    message_conclusion(mail_response)
    does_not_have_acknowledgments(mail_response)
  end

  def submitted_intro_for_general_users
    # Should have expected user message which is defined under submitted_general_users_message
    # Should have standard message conclusion
    # Should show acknowledgments 
    submitted_general_users_message
    message_conclusion(mail.body.parts.first.body)
    does_have_acknowledgments
  end

  #### GET A COST ESTIMATE ####
  def get_a_cost_estimate_intro_for_admin
    # Should have expected service provider message which is defined under get_a_cost_estimate_service_provider_admin_message
    # Should have 'Administrators/Service Providers, Click Here' link
    # Should have standard message conclusion
    # Should NOT show acknowledgments 
    get_a_cost_estimate_service_provider_admin_message(mail.body.parts.first.body)
    service_provider_and_admin_link(mail.body.parts.first.body)
    message_conclusion(mail.body.parts.first.body)
    does_not_have_acknowledgments(mail.body.parts.first.body)
  end

  def get_a_cost_estimate_intro_for_service_providers
    # Should have expected service provider message which is defined under get_a_cost_estimate_service_provider_admin_message
    # Should have 'Administrators/Service Providers, Click Here' link
    # Should have standard message conclusion
    # Should NOT show acknowledgments 
    get_a_cost_estimate_service_provider_admin_message(mail.body)
    service_provider_and_admin_link(mail.body)
    message_conclusion(mail.body)
    does_not_have_acknowledgments(mail.body)
  end

  def get_a_cost_estimate_intro_for_general_users
    # Should have expected user message which is defined under get_a_cost_estimate_general_users
    # Should have standard message conclusion
    # Should show acknowledgments 
    get_a_cost_estimate_general_users
    message_conclusion(mail.body.parts.first.body)
    does_have_acknowledgments
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end