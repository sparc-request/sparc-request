require "spec_helper"
describe "Audit Reporting", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study
 
  before :each do
    create_visits
    #build_clinical_data(all_subjects = true)
    sub_service_request.update_attributes(:in_work_fulfillment => true)
    visit study_tracker_sub_service_request_path sub_service_request.id
    #admin_organizations 
    click_link("Audit Reporting") 
    wait_for_javascript_to_finish
  end
describe "generating an audit report" do 
    it "should pick a start date" do 
      wait_for_javascript_to_finish
      find(:xpath, "//input[@id='cwf_audit_start_date']").click
      page.execute_script %Q{ $('#protocol_end_date_picker:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-prev').trigger("click") } # move one month backward
      page.execute_script %Q{ $("a.ui-state-default:contains('1')").trigger("click") } # click on day 1
      page.find('#cwf_audit_start_date_input').should_not have_value nil
    end 
    # it "should pick an end date" do 
    # end 
    # it "should pick different services" do 
    # end 
    # it "should generate a report" do 
    # end 
  end 
end 