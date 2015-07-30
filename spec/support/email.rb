module EmailHelpers

  def assert_email_project_information
    #assert correct protocol information is included in notification email
    expect(mail).to have_xpath "//table//strong[text()='Project Information']"
    expect(mail).to have_xpath "//th[text()='Project ID:']/following-sibling::td[text()='#{service_request.protocol.id}']"
    expect(mail).to have_xpath "//th[text()='Short Title:']/following-sibling::td[text()='#{service_request.protocol.short_title}']"
    expect(mail).to have_xpath "//th[text()='Project Title:']/following-sibling::td[text()='#{service_request.protocol.title}']"
    expect(mail).to have_xpath "//th[text()='Sponsor Name:']/following-sibling::td[text()='#{service_request.protocol.sponsor_name}']"
    expect(mail).to have_xpath "//th[text()='Funding Source:']/following-sibling::td[text()='#{service_request.protocol.funding_source.capitalize}']"
  end

  def assert_email_project_roles
    #assert correct project roles information is included in notification email
    expect(mail).to have_xpath "//table//th[text()='Name:']/following-sibling::th[text()='Role:']/following-sibling::th[text()='Proxy Rights:']"
    service_request.protocol.project_roles.each do |role|
      expect(mail).to have_xpath "//td[text()='#{role.identity.full_name}']/following-sibling::td[text()='#{role.role.upcase}']/following-sibling::td[text()='#{PROXY_RIGHTS.invert[role.project_rights]}']"
    end
  end

  def assert_email_admin_information
    #assert correct admin information is included in notification email
    expect(mail).to have_xpath "//table//strong[text()='Admin Information']"
    expect(mail).to have_xpath "//th[text()='Current Identity:']/following-sibling::td[text()='#{identity.id}']"
    expect(mail).to have_xpath "//th[text()='Service Request ID:']/following-sibling::td[text()='#{service_request.id}']"
    expect(mail).to have_xpath "//th[text()='Sub Service Request IDs:']/following-sibling::td[text()='#{service_request.sub_service_requests.map{ |ssr| ssr.id }.join(", ")}']"
  end

  def assert_notification_email_tables
    assert_email_project_information
    assert_email_project_roles
    assert_email_admin_information
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end
