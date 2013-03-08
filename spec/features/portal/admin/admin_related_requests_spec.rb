require 'spec_helper'

describe "admin related service requests tab", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    add_visits
    visit portal_admin_sub_service_request_path sub_service_request.id
    find("a.related_service_requests-tab").click
    wait_for_javascript_to_finish
  end

  it "should list the service request" do
    within "div#related_service_requests" do
      find("#requests tr td:first").should have_content("#{sub_service_request.ssr_id}")
    end
  end

  it "should show the first service when the plus link is clicked" do
    find("div#requests td a.rsr-link").click
    wait_for_javascript_to_finish
    find("div#ssr_#{sub_service_request.id}").should have_content("#{sub_service_request.line_items.first.service.name}")
  end

  it "should also show the second service when the plus link is clicked" do
    find("div#requests td a.rsr-link").click
    wait_for_javascript_to_finish
    find("div#ssr_#{sub_service_request.id}").should have_content("#{sub_service_request.line_items.last.service.name}")
  end

end
