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

    it 'should be able to search' do
      sleep 5
      find("h3#blue-provider-#{service_request.protocol_id} a").click
      sleep 2
      page.fill_in 'search_box', :with => '2'
      find("ul.ui-autocomplete li.ui-menu-item a.ui-corner-all").click
      find("div.protocol-information-#{service_request.protocol_id}").visible?.should eq(true)
    end

  end
end