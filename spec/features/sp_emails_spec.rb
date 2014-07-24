require 'spec_helper'
require 'surveyor/parser'
require 'rake'

describe "Service Provider Emails", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    add_visits
    visit review_service_request_path service_request.id
  end

  describe "clicking submit on the review page" do
    it "should send emails to user, admins, and service providers", :js => true do
      find("#submit_services2").click
      wait_for_javascript_to_finish
      click_button("No")
      wait_for_javascript_to_finish
      sp_email = get_mail(service_request.id, sub_service_request.id, role = 'service provider')
      user_email = get_mail(service_request.id, sub_service_request.id, role = 'user')
      admin_email = get_mail(service_request.id, sub_service_request.id, role = 'admin')
      visit_email sp_email
    end
  end
end