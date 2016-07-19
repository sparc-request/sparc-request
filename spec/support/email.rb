module EmailHelpers

  def assert_email_project_information
    #assert correct protocol information is included in notification email
    expect(mail).to have_xpath "//table//strong[text()='Project Information']"
    expect(mail).to have_xpath "//th[text()='Project ID']/following-sibling::td[text()='#{service_request.protocol.id}']"
    expect(mail).to have_xpath "//th[text()='Short Title']/following-sibling::td[text()='#{service_request.protocol.short_title}']"
    expect(mail).to have_xpath "//th[text()='Project Title']/following-sibling::td[text()='#{service_request.protocol.title}']"
    expect(mail).to have_xpath "//th[text()='Sponsor Name']/following-sibling::td[text()='#{service_request.protocol.sponsor_name}']"
    expect(mail).to have_xpath "//th[text()='Funding Source']/following-sibling::td[text()='#{service_request.protocol.funding_source.capitalize}']"
  end

  def assert_email_user_information
    #assert correct project roles information is included in notification email
    expect(mail).to have_xpath "//table//strong[text()='User Information']"
    expect(mail).to have_xpath "//th[text()='User Name']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']"
    service_request.protocol.project_roles.each do |role|
      if identity.id == role.identity.id
        requester_flag = " (Requester)"
      else
        requester_flag = ""
      end
      expect(mail).to have_xpath "//td[text()='#{role.identity.full_name}']/following-sibling::td[text()='#{role.identity.email}']/following-sibling::td[text()='#{role.role.upcase}#{requester_flag}']"
    end
  end

  def assert_email_srid_information
    expect(mail).to have_xpath "//th[text()='SRID']/following-sibling::th[text()='Organization']/following-sibling::th[text()='Status']"
    service_request.protocol.sub_service_requests.each do |ssr|
      status = AVAILABLE_STATUSES[ssr.status]
      expect(mail).to have_xpath "//td[text()='#{ssr.display_id}']/following-sibling::td[text()='#{ssr.org_tree_display}']/following-sibling::td[text()='#{status}']"
    end
  end

  def assert_notification_email_tables
    assert_email_project_information
    assert_email_user_information
    assert_email_srid_information
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end
