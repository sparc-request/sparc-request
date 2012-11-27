require 'spec_helper'

describe "creating a new study " do 

  before :each do
    visit root_path
    visit new_service_request_study_path 1
    find(:xpath, "//input[@alt='SaveAndContinue']").click
  end

  describe "submitting a blank form" do

    it "should show errors when submitting a blank form", :js => true do
      find('#errorExplanation').visible?().should eq(true)
    end

    it "should require a protocol title", :js => true do
      page.should have_content("Title can't be blank")
    end
  end

  describe "submitting a filled form", :js => true do

    it "should clear errors and submit the form" do
      sleep 1
      fill_in "study_short_title", :with => "Bob"
      fill_in "study_title", :with => "Dole"
      select "Funded", :from => "study_funding_status"
      select "Federal", :from => "study_funding_source"

      select "PD/PI", :from => "project_role_role"
      click_button "Add Authorized User"
      sleep 1

      find(:xpath, "//input[@alt='SaveAndContinue']").click

      find("#service_request_protocol_id").value().should eq("1")
    end
  end
end

describe "editing a study" do

  let!(:service_request) { FactoryGirl.create(:service_request, subject_count: 5, visit_count: 5, status: "draft") }
  let!(:service)         { FactoryGirl.create(:service) }
  let!(:service2)        { FactoryGirl.create(:service) }
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, status: "draft")}
  let(:line_item)        { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id) }
  let(:line_item2)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id) }

  before :each do
    protocol = Study.create(FactoryGirl.attributes_for(:protocol))
    protocol.save :validate => false
    FactoryGirl.create(:project_role, protocol_id: protocol.id, identity_id: Identity.find_by_ldap_uid("jug2"), project_rights: "approve", role: "pi")
    service_request.update_attribute(:protocol_id, protocol.id)
    visit protocol_service_request_path service_request.id
  end

  describe "editing the short title", :js => true do

    it "should save the short title" do
      click_button("Edit Study")
      select "Funded", :from => "study_funding_status"
      select "Federal", :from => "study_funding_source"
      fill_in "study_short_title", :with => "Bob"
      find(:xpath, "//input[@alt='SaveAndContinue']").click
      click_button("Edit Study")

      find("#study_short_title").value().should eq("Bob")
    end
  end

end