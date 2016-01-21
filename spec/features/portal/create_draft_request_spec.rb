require 'rails_helper'

RSpec.describe 'creating a draft service request from user portal', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_empty_study

  let!(:institution)  { create(:institution, name: 'Medical University of South Carolina', order: 1, abbreviation: 'MUSC', is_available: 1) }
  let!(:provider)     { create(:provider, name: 'South Carolina Clinical and Translational Institute (SCTR)', order: 1,
                               css_class: 'blue-provider', parent_id: institution.id, abbreviation: 'SCTR1', process_ssrs: 0, is_available: 1) }
  let!(:program)      { create(:program_with_pricing_setup, name: 'Office of Biomedical Informatics', order: 1, parent_id: provider.id,
                               abbreviation:'Informatics') }
  let!(:core)         { create(:core, type: 'Core', name: 'Clinical Data Warehouse', order: 1, parent_id: program.id,
                               abbreviation: 'Clinical Data Warehouse') }
  let!(:service)      { create(:service, name: 'MUSC Research Data Request (CDW)', abbreviation: 'CDW', order: 1, cpt_code: '',
                               organization_id: core.id, one_time_fee: true) }
  let!(:service2)     { create(:service, name: 'Breast Milk Collection', abbreviation: 'Breast Milk Collection', order: 1, cpt_code: '',
                               organization_id: core.id) }
  let!(:pricing_map)  { create(:pricing_map, service_id: service.id, unit_type: 'Per Query', unit_factor: 1, full_rate: 0,
                               exclude_from_indirect_cost: 0, unit_minimum: 1) }
  let!(:pricing_map2) { create(:pricing_map, service_id: service2.id, unit_type: 'Per patient/visit', unit_factor: 1, full_rate: 636,
                               exclude_from_indirect_cost: 0, unit_minimum: 1) }

  scenario 'user adds services to empty protocol' do
    when_i_click_add_services
    then_a_draft_request_should_be_generated
  end

  scenario 'user adds services to a draft request without line items' do
    when_i_click_add_services
    when_i_click_add_services
    another_request_should_not_be_generated
  end

  scenario 'user adds line item on the root page' do
    when_i_click_add_services
    then_add_a_line_item
    a_sub_service_request_should_be_generated
    and_request_should_now_be_editable_in_portal
  end

  def when_i_click_add_services
    visit portal_root_path
    @protocol = Protocol.last
    wait_for_javascript_to_finish
    find('.add-services-button').click
    wait_for_javascript_to_finish
  end

  def then_a_draft_request_should_be_generated
    wait_for_javascript_to_finish
    service_request = ServiceRequest.where(protocol_id: @protocol.id).first
    expect(service_request.status).to eq('draft')
  end

  def another_request_should_not_be_generated
    expect(@protocol.service_requests.count).to eq(1)
  end

  def then_add_a_line_item
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    wait_for_javascript_to_finish
    click_link('Office of Biomedical Informatics')
    wait_for_javascript_to_finish
    find("#service-#{service.id}").click
    wait_for_javascript_to_finish
    find("button.ui-button .ui-button-text", text: "Yes").click
    wait_for_javascript_to_finish
  end

  def a_sub_service_request_should_be_generated
    service_request = ServiceRequest.where(protocol_id: @protocol.id).first
    expect(service_request.sub_service_requests.count).to eq(1)
  end

  def and_request_should_now_be_editable_in_portal
    visit portal_root_path
    wait_for_javascript_to_finish
    expect(page).to have_content('Edit')
    expect(page).to have_content('Clinical Data Warehouse')
  end
end