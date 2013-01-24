def let_there_be_lane
  let!(:jug2) { FactoryGirl.create(:identity, 
      last_name:             'Glenn',
      first_name:            'Julia',
      ldap_uid:              'jug2',
      institution:           'medical_university_of_south_carolina',
      college:               'college_of_medecine',
      department:            'other',
      email:                 'glennj@musc.edu',
      credentials:           'BS,    MRA',
      catalog_overlord:      true,
      password:              'p4ssword',
      password_confirmation: 'p4ssword',
      approved:              true
    )}
end

def build_service_request_with_project
  build_service_request()
  build_project()
end

def build_service_request_with_study
  build_service_request()
  build_study()
end

def build_service_request
  let!(:service_request) { FactoryGirl.create(:service_request, status: "draft", subject_count: 2, visit_count: 10, start_date: Time.now, end_date: Time.now + 10.days) }
  let!(:institution)  {FactoryGirl.create(:institution,name: 'Medical University of South Carolina', order: 1,obisid: '87d1220c5abf9f9608121672be000412',abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {FactoryGirl.create(:provider,parent_id:institution.id,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',obisid: '87d1220c5abf9f9608121672be0011ff',abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program) {FactoryGirl.create(:program,type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  # let!(:program2) {FactoryGirl.create(:program,type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id,status: "draft")}
  # One time fee service
  let!(:service)         { FactoryGirl.create(:service, organization_id:program.id, name: 'One Time Fee') }
  let!(:line_item)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id, quantity: 5, units_per_quantity: 1) }
  let!(:pricing_setup)   {FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map)     { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service.id, is_one_time_fee: true, display_date: Time.now - 1.day, full_rate: 2000) }
  # Per patient per visit service
  let!(:service2)        { FactoryGirl.create(:service, organization_id:program.id, name: 'Per Patient') }
  let!(:line_item2)      { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id, subject_count: 1, quantity: 0) }
  let!(:pricing_map2)    { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service2.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000) }
  let!(:service_provider) {FactoryGirl.create(:service_provider, organization_id: program.id, identity_id: jug2.id)}

  before :each do
    service_request.update_attribute(:service_requester_id, Identity.find_by_ldap_uid("jug2").id)
  end
end

def add_visits
  visit_names = ["I'm", "a", 'little', 'teapot', 'short', 'and', 'stout', 'visit', 'me', 'please']
  (1..service_request.visit_count).each do |index|
    FactoryGirl.create(:visit, line_item_id: line_item2.id, quantity: 0, name: visit_names[index - 1])
  end
end

def build_project
  before :each do
    protocol = Project.create(FactoryGirl.attributes_for(:protocol))
    protocol.update_attribute(:funding_status, "funded")
    protocol.update_attribute(:funding_source, "federal")
    protocol.update_attribute(:indirect_cost_rate, 50.0)
    protocol.save :validate => false
    identity = Identity.find_by_ldap_uid('jug2')
    FactoryGirl.create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity.id,
        project_rights:  "approve",
        role:            "pi")
    service_request.update_attribute(:protocol_id, protocol.id)
  end
end

def build_study
  before :each do
    protocol = Study.create(FactoryGirl.attributes_for(:protocol))
    protocol.update_attribute(:funding_status, "funded")
    protocol.update_attribute(:funding_source, "federal")
    protocol.update_attribute(:indirect_cost_rate, 50.0)
    protocol.save :validate => false
    identity = Identity.find_by_ldap_uid('jug2')
    FactoryGirl.create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity.id,
        project_rights:  "approve",
        role:            "pi")
    service_request.update_attribute(:protocol_id, protocol.id)
  end
end

def build_fake_notification
  let!(:sender) {FactoryGirl.create(:identity, last_name:'Glenn2', first_name:'Julia2', ldap_uid:'jug3', institution:'medical_university_of_south_carolina', college:'college_of_medecine', department:'other', email:'glennj2@musc.edu', credentials:'BS,    MRA', catalog_overlord: true, password:'p4ssword', password_confirmation:'p4ssword', approved: true)}
  let!(:notification) {FactoryGirl.create(:notification, sub_service_request_id: sub_service_request.id, originator_id: sender.id)}
  let!(:message) {FactoryGirl.create(:message, notification_id: notification.id, to: jug2.id, from: sender.id, email: "test@test.org", subject: "test message", body: "This is a test, and only a test")}
  let!(:user_notification) {FactoryGirl.create(:user_notification, identity_id: jug2.id, notification_id: notification.id, read: false)}
end

