require 'spec_helper'

describe "admin fulfillment tab" do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    add_visits
  end

  describe "ensure information is present" do
    before :each do
      visit portal_admin_sub_service_request_path(sub_service_request)
    end

    it "should contain the user header information" do
      page.should have_content('Julia Glenn (glennj@musc.edu)')
      page.should have_content(service_request.protocol.short_title)
      page.should have_content("#{service_request.protocol.id}-")
    end

    it "should contain the sub service request information" do
      page.should have_xpath("//option[@value='draft' and @selected='selected']")
      # More data checks here (more information probably needs to be put in the mocks)
    end

  end

  describe "changing attributes" do

    context "service request attributes" do
      
    end

    context "changing sub service request attributes" do

    end

    context "changing line item attributes" do

    end

    context "changing fulfillment attributes" do

    end

    context "changing visit attributes" do

    end

  end

  describe "notifications" do

  end

  describe "notes" do

  end

end