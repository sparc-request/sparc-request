require 'spec_helper'

describe "admin index page", :js => true do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_study

  context "with permissions to enter admin" do
    before :each do
      visit portal_admin_index_path
    end

    it "should allow access to the admin page" do
      page.should have_content 'My Dashboard'
    end

  end

  context "without permissions to enter admin" do

    it "should redirect to the root path" do
      service_provider.destroy
      visit portal_admin_index_path
      wait_for_javascript_to_finish
      page.should have_content('Welcome to the SPARC Services Catalog')
    end

  end

end