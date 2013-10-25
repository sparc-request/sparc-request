require 'spec_helper'

describe 'Full service request' do

  # before :each do
  #   create_default_data
  #   create_ctrc_data
  # end
  # let_there_be_j
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  context "without any existing arms" do

    before :each do
      project.arms.each {|x| x.destroy}
    end

    it "should create a complete service request", :js => true do
      ### CATALOG PAGE ###
      visit root_path

      click_link("MUSC Users + Outside Users with existing SPARC Request Accounts")

      click_link("South Carolina Clinical and Translational Institute (SCTR)")
      wait_for_javascript_to_finish
      find(".provider-name").should have_text("South Carolina Clinical and Translational Institute (SCTR)")

      click_link("Office of Biomedical Informatics")
      find("#service-1").click() # Add service 'Human Subject Review' to cart
      wait_for_javascript_to_finish

      # # TODO: Switch this to a search
      find("#service-2").click()
      wait_for_javascript_to_finish

      find(:xpath, "//a/img[@alt='Submit_request']/..").click # Submit to begin services

      ### LOGIN PAGE ###
      fill_in("identity_ldap_uid", :with => 'jug2')
      fill_in("identity_password", :with => 'p4ssword')
      click_button("Sign in")

      ### PROJECT/STUDY PAGE ###
      within("#select-type") do
        find("option[value='Research Project']").click
      end

      within("#service_request_protocol_id") do
        find("option[value='1']").click # PROBABLY WONT WORK
      end

      project.arms.count.should eq(0)

      find(:xpath, "//a/img[@alt='Savecontinue']/..").click

      ### SERVICE REQUEST SETUP PAGE ###
      project.arms.count.should eq(1)
      page.execute_script %Q{ $('#start_date').trigger("focus") } # activate datetime picker
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15

      page.execute_script %Q{ $('#end_date').trigger("focus") } # activate datetime picker
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15

      find("#project_arms_attributes_0_name").should have_value("ARM 1")
      fill_in("project_arms_attributes_0_subject_count", :with => 10)
      fill_in("project_arms_attributes_0_visit_count", :with => 10)

      find(:xpath, "//a/img[@alt='Savecontinue']/..").click

      # sleep 10000
    end

  end # context 'without existing arms'

  context "with existing arms" do

  end

end