require 'rails_helper'

RSpec.describe 'User should see notes', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    institution   = create(:institution, name: "Institution")
    provider      = create(:provider, name: "Provider", parent: institution)
    program       = create(:program, name: "Program", parent: provider, process_ssrs: true)
    service       = create(:service_with_pricing_map, name: 'Brain Removal')
    @protocol     = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr           = create(:service_request_without_validations, status: 'first_draft', protocol: @protocol)
    ssr           = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                    create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
                    create(:arm, protocol: @protocol, visit_count: 1)
    visit document_management_service_request_path(@sr)
    wait_for_javascript_to_finish
  end

  scenario 'User creates note and then views it on Review page' do
    click_button 'Add a Note'
    expect(page).to have_css('#new-note-modal')
    fill_in 'note_body', with: 'test'
    click_button 'Add'
    wait_for_javascript_to_finish
    expect(page).to have_css('td.note', text: 'test')
    click_link 'Save and Continue'
    expect(page).to have_content 'test'
  end
end
