require 'spec_helper'

describe 'adding an additional service', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do

    visit portal_root_path
    wait_for_javascript_to_finish
  end

  describe 'clicking the button' do

    it "should redirect to the application root page" do
      find('.service-request-button').click
      wait_for_javascript_to_finish
      page.should have_content("Welcome to the SPARC Request Services Catalog")
    end
  end
end