require 'spec_helper'

describe "Reviewing the page" do
  let!(:service_request) { FactoryGirl.create(:service_request, status: "draft") }
  let!(:institution)  {FactoryGirl.create(:institution,name: 'Medical University of South Carolina', order: 1,obisid: '87d1220c5abf9f9608121672be000412',abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {FactoryGirl.create(:provider,parent_id:institution.id,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',obisid: '87d1220c5abf9f9608121672be0011ff',abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program) {FactoryGirl.create(:program,type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:service)         { FactoryGirl.create(:service, organization_id:program.id) }
  let!(:service2)        { FactoryGirl.create(:service, organization_id:program.id) }
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id,status: "draft")}
  let!(:line_item)        { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id) }
  let!(:line_item2)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id) }
  let!(:pricing_setup)   {FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map)     { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service.id, is_one_time_fee: true, display_date: Time.now - 1.day) }
  let!(:visit)  {FactoryGirl.create(:visit, line_item_id: line_item.id, quantity: 1, billing: "R")}

  before :each do
    protocol = Project.create(FactoryGirl.attributes_for(:protocol))
    protocol.update_attribute(:funding_status, "funded")
    protocol.update_attribute(:funding_source, "federal")
    protocol.save :validate => false
    FactoryGirl.create(:project_role, protocol_id: protocol.id, identity_id: Identity.find_by_ldap_uid("jug2"), project_rights: "approve", role: "pi")
    service_request.update_attribute(:protocol_id, protocol.id)
  end

  describe "clicking submit" do
    it 'Should submit the page', :js => true do
      visit root_path
      sleep 1
      visit review_service_request_path 1
      sleep 5
    end
  end

end