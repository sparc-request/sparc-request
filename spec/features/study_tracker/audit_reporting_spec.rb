require "spec_helper"
describe "Audit Reporting", :js => true do
  let_there_be_lane
  # Per patient per visit service
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project_and_one_time_fees_only
  let!(:protocol_for_service_request_id) {project.id rescue study.id}
  let!(:arm1)                { FactoryGirl.create(:arm, name: "Arm", protocol_id: protocol_for_service_request_id, visit_count: 10, subject_count: 2)}
  let!(:arm2)                { FactoryGirl.create(:arm, name: "Arm2", protocol_id: protocol_for_service_request_id, visit_count: 5, subject_count: 4)}
  let!(:visit_group1)         { FactoryGirl.create(:visit_group, arm_id: arm1.id, position: 1, day: 1)}
  let!(:visit_group2)         { FactoryGirl.create(:visit_group, arm_id: arm2.id, position: 1, day: 1)}
  let!(:service2)            { FactoryGirl.create(:service, organization_id: program.id, name: 'Per Patient') }
  let!(:pricing_setup)       { FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map2)        { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service2.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20) }
  let!(:line_item2)          { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id, quantity: 0) }
  let!(:service_provider)    { FactoryGirl.create(:service_provider, organization_id: program.id, identity_id: jug2.id)}
  let!(:super_user)          { FactoryGirl.create(:super_user, organization_id: program.id, identity_id: jug2.id)}#changed to lane here be careful to ensure this doesn't break anything else
  let!(:catalog_manager)     { FactoryGirl.create(:catalog_manager, organization_id: program.id, identity_id: jpl6.id) }
  let!(:clinical_provider)   { FactoryGirl.create(:clinical_provider, organization_id: program.id, identity_id: jug2.id) }
  let!(:available_status)    { FactoryGirl.create(:available_status, organization_id: program.id, status: 'submitted')}
  let!(:available_status2)   { FactoryGirl.create(:available_status, organization_id: program.id, status: 'draft')}
  let!(:subsidy)             { FactoryGirl.create(:subsidy, pi_contribution: 2500, sub_service_request_id: sub_service_request.id)}
  let!(:subsidy_map)         { FactoryGirl.create(:subsidy_map, organization_id: program.id) }
  before :each do
    create_visits
    sub_service_request.update_attributes(:in_work_fulfillment => true)
    visit study_tracker_sub_service_request_path sub_service_request.id
    click_link("Audit Reporting") 
    wait_for_javascript_to_finish
  end
describe "generating an audit report" do 
    it "should pick a start date" do 
      wait_for_javascript_to_finish
      find(:xpath, "//input[@name='cwf_audit_start_date_input']").click
      page.execute_script %Q{ $('#protocol_start_date_picker:visible').focus() }
      day = Time.now.day
      page.execute_script %Q{ $("a.ui-state-default:contains('#{day}')").trigger("click") } # click on day 1
      page.find('#cwf_audit_start_date_input').should_not eq nil
    end 
    it "should pick an end date" do
      wait_for_javascript_to_finish
      find(:xpath, "//input[@name='cwf_audit_end_date_input']").click
      page.execute_script %Q{ $('#protocol_end_date_picker:visible').focus() }
      day = Time.now
      page.execute_script %Q{ $("a.ui-state-default:contains('#{day}')").trigger("click") } # click on day 1 in the current month
      page.find('#cwf_audit_end_date_input').should_not eq nil
    end 
    it "should generate a report" do 
      wait_for_javascript_to_finish
      find(:xpath, "//input[@name='cwf_audit_start_date_input']").click
      page.execute_script %Q{ $('#protocol_start_date_picker:visible').focus() }
      day = Time.now.day
      page.execute_script %Q{ $("a.ui-state-default:contains('#{day}')").trigger("click") }
      page.execute_script %Q{ $('#protocol_end_date_picker:visible').focus() }
      page.execute_script %Q{ $("a.ui-state-default:contains('#{day}')").trigger("click") } # click on day 1 in the current month
      wait_for_javascript_to_finish
      click_button "Get Report"
      page.driver.browser.window_handles.length.should == 1
    end 
  end 
end 