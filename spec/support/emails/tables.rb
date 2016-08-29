module EmailHelpers

  def assert_email_project_information(mail_response)
    #assert correct protocol information is included in notification email
    expect(mail_response).to have_xpath "//table//strong[text()='Project Information']"
    expect(mail_response).to have_xpath "//th[text()='Project ID']/following-sibling::td[text()='#{service_request.protocol.id}']"
    expect(mail_response).to have_xpath "//th[text()='Short Title']/following-sibling::td[text()='#{service_request.protocol.short_title}']"
    expect(mail_response).to have_xpath "//th[text()='Project Title']/following-sibling::td[text()='#{service_request.protocol.title}']"
    expect(mail_response).to have_xpath "//th[text()='Sponsor Name']/following-sibling::td[text()='#{service_request.protocol.sponsor_name}']"
    expect(mail_response).to have_xpath "//th[text()='Funding Source']/following-sibling::td[text()='#{service_request.protocol.funding_source.capitalize}']"
  end

  def assert_email_user_information(mail_response)
    expect(mail_response).to have_xpath "//table//strong[text()='User Information']"
    expect(mail_response).to have_xpath "//th[text()='User Name']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']"
    service_request.protocol.project_roles.each do |role|
      if identity.id == service_request.sub_service_requests.first.service_requester_id
        requester_flag = " (Requester)"
      else
        requester_flag = ""
      end
      expect(mail_response).to have_xpath "//td[text()='#{role.identity.full_name}']/following-sibling::td[text()='#{role.identity.email}']/following-sibling::td[text()='#{role.role.upcase}#{requester_flag}']"
    end
  end

  def assert_email_user_information_when_selected_for_epic(mail_response)
    # Should display 'Epic Access' column
    expect(mail_response).to have_xpath "//table//strong[text()='User Information']"
    expect(mail_response).to have_xpath "//th[text()='User Name']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']/following-sibling::th[text()='Epic Access']"
    service_request.protocol.project_roles.each do |role|
      if identity.id == service_request.sub_service_requests.first.service_requester_id
        requester_flag = " (Requester)"
      else
        requester_flag = ""
      end

      user_epic_access = role.epic_access == false ? "No" : "Yes"
      expect(mail_response).to have_xpath "//td[text()='#{role.identity.full_name}']/following-sibling::td[text()='#{role.identity.email}']/following-sibling::td[text()='#{role.role.upcase}#{requester_flag}']/following-sibling::td[text()='#{user_epic_access}']"
    end
  end

  def assert_email_srid_information_for_service_provider
    # Expect table to show only SSR's (hyper-link) that are associated with service provider 
    expect(mail.body).to have_xpath "//table//strong[text()='Service Request Information']"
    expect(mail.body).to have_xpath "//th[text()='SRID']/following-sibling::th[text()='Organization']/following-sibling::th[text()='Status']"
    status = AVAILABLE_STATUSES[service_request.protocol.sub_service_requests.first.status]
    expect(mail.body).to have_xpath "//td//a[@href='/dashboard/sub_service_requests/#{service_request.protocol.sub_service_requests.first.id}']['#{service_request.protocol.sub_service_requests.first.display_id}']/@href"
    expect(mail.body).to have_xpath "//td[text()='#{service_request.protocol.sub_service_requests.first.org_tree_display}']/following-sibling::td[text()='#{status}']"
  end

  def assert_email_srid_information_for_admin
    # Expect table to show all SSR's with hyper-link
    expect(mail.body.parts.first.body).to have_xpath "//table//strong[text()='Service Request Information']"
    expect(mail.body.parts.first.body).to have_xpath "//th[text()='SRID']/following-sibling::th[text()='Organization']/following-sibling::th[text()='Status']"
    # Only display SSRs that are associated with that submission email
    displayed_service_request = service_request.protocol.sub_service_requests.first
    status = AVAILABLE_STATUSES[displayed_service_request.status]
    expect(mail.body.parts.first.body).to have_xpath "//td//a[@href='/dashboard/sub_service_requests/#{displayed_service_request.id}']['#{displayed_service_request.display_id}']/@href"
    expect(mail.body.parts.first.body).to have_xpath "//td[text()='#{displayed_service_request.org_tree_display}']/following-sibling::td[text()='#{status}']"       
  end

  def assert_email_srid_information_for_user
    # Expect table to show all SSR's without hyper-link
    expect(mail).to have_xpath "//table//strong[text()='Service Request Information']"
    expect(mail).to have_xpath "//th[text()='SRID']/following-sibling::th[text()='Organization']/following-sibling::th[text()='Status']"

    service_request.protocol.sub_service_requests.each do |ssr|
      status = AVAILABLE_STATUSES[ssr.status]
      expect(mail.body.parts.first.body).to have_xpath "//td[text()='#{ssr.display_id}']/following-sibling::td[text()='#{ssr.org_tree_display}']/following-sibling::td[text()='#{status}']"
    end
  end

  def assert_notification_email_tables_for_service_provider
    assert_email_project_information(mail.body)
    assert_email_user_information(mail.body)
    assert_email_srid_information_for_service_provider
  end

  def assert_notification_email_tables_for_admin
    assert_email_project_information(mail.body.parts.first.body)
    assert_email_user_information(mail.body.parts.first.body)
    assert_email_srid_information_for_admin
  end

  def assert_notification_email_tables_for_user
    assert_email_project_information(mail.body.parts.first.body)
    assert_email_user_information(mail.body.parts.first.body)
    assert_email_srid_information_for_user
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end
