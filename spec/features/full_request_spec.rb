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

      click_link("South Carolina Clinical and Translational Institute (SCTR)")
      wait_for_javascript_to_finish
      find(".provider-name").should have_text("South Carolina Clinical and Translational Institute (SCTR)")

      click_link("Office of Biomedical Informatics")
      find("#service-1").click() # Add service 'Human Subject Review' to cart
      wait_for_javascript_to_finish

      # # TODO: Switch this to a search
      find("#service-2").click()
      wait_for_javascript_to_finish

      find(".submit-request-button").click # Submit to begin services

      click_link "Outside Users Click Here"
      ### LOGIN PAGE ###
      fill_in("identity_ldap_uid", :with => 'jug2')
      fill_in("identity_password", :with => 'p4ssword')
      find(".devise_submit_button").click
    end
  end
end