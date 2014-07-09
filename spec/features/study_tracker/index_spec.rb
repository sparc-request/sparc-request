require 'spec_helper'

describe "study tracker index page", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    add_visits
    sub_service_request.update_attributes(:in_work_fulfillment => true)
    service_provider.destroy
  end

  context "with clinical provider rights" do
    before :each do
      visit study_tracker_root_path
    end

    it "should allow access to the study tracker page if the user is a clinical provider" do
      page.should have_content 'Dashboard'
    end

    it "should have a service request listed in draft status" do
      page.should have_content 'Draft (1)'
    end

    it "should show sub service requests for the status I have selected" do
      select('Draft (1)', :from => 'service_request_workflow_states')
      wait_for_javascript_to_finish
      page.should have_content(service_request.protocol.short_title)
    end

    describe "search functionality" do

      it "should search by protocol id" do
        find('.search-all-service-requests').set("#{service_request.protocol.id}")
        find('.ui-autocomplete').should have_content("#{service_request.protocol.id}")
      end

      it "should search by service requester" do
        find('.search-all-service-requests').set('glenn')
        find('.ui-autocomplete').should have_content('Julia Glenn')
      end

      it "should search by PI" do
        new_pi = FactoryGirl.create(:identity, :last_name => 'Ketchum', :first_name => 'Ash')
        FactoryGirl.create(:project_role, :protocol_id => service_request.protocol_id, :identity_id => new_pi.id, :role => 'primary-pi')
        ProjectRole.find_by_identity_id(jug2.id).update_attribute(:role, 'co-investigator')
        visit study_tracker_root_path
        find('.search-all-service-requests').set('ketchum')
        find('.ui-autocomplete').should have_content('Ash Ketchum')
      end

      it "should filter sub service requests if I select a search result" do
        find('.search-all-service-requests').set('glenn')
        wait_for_javascript_to_finish
        find('ul.ui-autocomplete a').click
        wait_for_javascript_to_finish
        page.should have_content(service_request.protocol.short_title)
      end

    end

    describe "opening a sub service request" do

      before :each do
        select('Draft (1)', :from => 'service_request_workflow_states')
        wait_for_javascript_to_finish
      end

      it "should not open if I click an expandable field" do
        find('ul.services_first li').click()
        wait_for_javascript_to_finish
        page.should_not have_content('Send Notifications')
      end

      it "should open a sub service request if I click that sub service request" do
        find('td', :text => "#{service_request.protocol.id}-").click
        wait_for_javascript_to_finish
        page.should have_content('Return to Clinical Work Fulfillment Home')
      end

    end

  end

  context "without clinical provider rights" do

    before :each do
      clinical_provider.destroy
    end

    context "with no rights" do
      it "should redirect to the root path" do
        visit study_tracker_root_path
        wait_for_javascript_to_finish
        page.should have_content('Welcome to the SPARC Request Services Catalog')
      end
    end

    context "with super user rights" do
      it "should allow access to the study tracker page if the user is a super user for sctr" do
        FactoryGirl.create(:super_user, identity_id: jug2.id, organization_id: provider.id)
        provider.tag_list = "ctrc"
        provider.save
        visit study_tracker_root_path
        page.should have_content 'Dashboard'
      end
    end

  end

end