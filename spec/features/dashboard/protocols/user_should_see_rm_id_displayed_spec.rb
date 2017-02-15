require 'rails_helper'

RSpec.describe 'User should see RM ID displayed', js: true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  fake_login_for_each_test("johnd")

  scenario 'successfully' do
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: 1
    )

    visit dashboard_protocol_path(protocol)
    find('.view-protocol-details-button').click

    expect(page).to have_content 'Research Master ID: 1'
  end

  scenario 'successfully' do
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: 1
    )

    visit dashboard_protocol_path(protocol)
    expect(page).to have_content "Research Master ID: #{protocol.research_master_id}"
  end

  scenario 'successfully - No RMID' do
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: nil
    )

    visit dashboard_protocol_path(protocol)
    find('.view-protocol-details-button').click

    expect(page).to have_content 'Research Master ID: Not Available'
  end

  scenario 'successfully - Step 1' do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(
      :program, name: "Program", parent: provider, process_ssrs: true
    )
    service     = create(
      :service, name: "Service", abbreviation: "Service", organization: program
    )
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: 1
    )
    sr = create(
      :service_request_without_validations,
      status: 'first_draft',
      protocol: protocol
    )
    ssr = create(
      :sub_service_request_without_validations,
      service_request: @sr, organization: program, status: 'first_draft'
    )
    create(
      :line_item,
      service_request: sr, sub_service_request: ssr, service: service
    )
    create(:arm, protocol: protocol, visit_count: 1)
    create(
      :subsidy_map, organization: program, max_dollar_cap: 100, max_percentage: 100
    )

    visit protocol_service_request_path(sr)

    click_button 'View Study Details'

    expect(page).to have_content 'Research Master ID: 1'
  end

  scenario 'successfully - Step 1' do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(
      :program, name: "Program", parent: provider, process_ssrs: true
    )
    service     = create(
      :service, name: "Service", abbreviation: "Service", organization: program
    )
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: 1
    )
    sr = create(
      :service_request_without_validations,
      status: 'first_draft',
      protocol: protocol
    )
    ssr = create(
      :sub_service_request_without_validations,
      service_request: @sr, organization: program, status: 'first_draft'
    )
    create(
      :line_item,
      service_request: sr, sub_service_request: ssr, service: service
    )
    create(:arm, protocol: protocol, visit_count: 1)
    create(
      :subsidy_map, organization: program, max_dollar_cap: 100, max_percentage: 100
    )

    visit protocol_service_request_path(sr)

    expect(page).to have_content 'Research Master ID: 1'
  end


  scenario 'successfully - Step 1' do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(
      :program, name: "Program", parent: provider, process_ssrs: true
    )
    service     = create(
      :service, name: "Service", abbreviation: "Service", organization: program
    )
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: nil
    )
    sr = create(
      :service_request_without_validations,
      status: 'first_draft',
      protocol: protocol
    )
    ssr = create(
      :sub_service_request_without_validations,
      service_request: @sr, organization: program, status: 'first_draft'
    )
    create(
      :line_item,
      service_request: sr, sub_service_request: ssr, service: service
    )
    create(:arm, protocol: protocol, visit_count: 1)
    create(
      :subsidy_map, organization: program, max_dollar_cap: 100,
      max_percentage: 100
    )

    visit protocol_service_request_path(sr)

    click_button 'View Study Details'

    expect(page).to have_content 'Research Master ID: Not Available'
  end
end
