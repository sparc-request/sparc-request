require 'spec_helper'

describe "submitting a filled in form" do
  let!(:service_request) { FactoryGirl.create(:service_request, status: "draft") }
  let!(:institution)  {FactoryGirl.create(:institution,name: 'Medical University of South Carolina', order: 1,obisid: '87d1220c5abf9f9608121672be000412',abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {FactoryGirl.create(:provider,parent_id:institution.id,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',obisid: '87d1220c5abf9f9608121672be0011ff',abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program) {FactoryGirl.create(:program,type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:service)         { FactoryGirl.create(:service, organization_id:program.id) }
  let!(:service2)        { FactoryGirl.create(:service, organization_id:program.id) }
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id,status: "draft")}
  let!(:line_item)        { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id) }
  let!(:line_item2)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id) }
  let!(:pricing_setup)   {FactoryGirl.create(:pricing_setup, organization_id: program.id)}
  let!(:pricing_map)     { FactoryGirl.create(:pricing_map, service_id: service.id, is_one_time_fee: true, display_date: '2006-12-1') }

  before :each do
    protocol = Project.create(FactoryGirl.attributes_for(:protocol))
    protocol.save :validate => false
    FactoryGirl.create(:project_role, protocol_id: protocol.id, identity_id: Identity.find_by_ldap_uid("jug2"), project_rights: "approve", role: "pi")
    service_request.update_attribute(:protocol_id, protocol.id)
  end

  describe "submitting a completed form" do
    it 'Submit Request', :js => true do

      visit root_path
      sleep 1
      visit service_details_service_request_path 1
      sleep 1
      fill_in "service_request_visit_count", :with => "20"
      sleep 1
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      sleep 5
    end
  end
end