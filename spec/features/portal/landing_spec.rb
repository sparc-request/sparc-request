require 'spec_helper'

describe "landing page", :js => true do
  let_there_be_lane
  fake_login_for_each_test

  describe "with no requests" do
    it 'should be empty' do
      visit portal_root_path
      page.should_not have_css("div#protocol-accordion h3")
    end
  end

  describe "with requests" do
    build_service_request_with_project

    before :each do
      visit portal_root_path
    end

    it 'should have requests' do
      page.should have_css("div#protocol-accordion h3")
    end
    
  end
end