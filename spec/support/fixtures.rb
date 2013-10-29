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

def let_there_be_j
  let!(:jpl6) { FactoryGirl.create(:identity, 
      last_name:             'Leonard',
      first_name:            'Jason',
      ldap_uid:              'jpl6@musc.edu',
      institution:           'medical_university_of_south_carolina',
      college:               'college_of_medecine',
      department:            'other',
      email:                 'leonarjp@musc.edu',
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
  build_arms()
  build_one_time_fee_services()
  build_per_patient_per_visit_services()
end

def build_service_request_with_project_and_one_time_fees_only
  build_service_request()
  build_project()
  build_one_time_fee_services()
end

def build_service_request_with_project_and_per_patient_per_visit_only
  build_service_request()
  build_project()
  build_arms()
  build_per_patient_per_visit_services() 
end

def build_service_request_with_study
  build_service_request()
  build_study()
  build_arms()
  build_one_time_fee_services()
  build_per_patient_per_visit_services()
end

def build_one_time_fee_services
  # One time fee service
  let!(:service)             { FactoryGirl.create(:service, organization_id: program.id, name: 'One Time Fee') }
  let!(:line_item)           { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id, quantity: 5, units_per_quantity: 1) }
  let!(:pricing_setup)       { FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map)         { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service.id, is_one_time_fee: true, display_date: Time.now - 1.day, full_rate: 2000, units_per_qty_max: 20) }
end

def build_per_patient_per_visit_services
  # Per patient per visit service
  let!(:service2)            { FactoryGirl.create(:service, organization_id: program.id, name: 'Per Patient') }
  let!(:pricing_setup)       { FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map2)        { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service2.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20) }
  let!(:line_item2)          { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id, quantity: 0) }
  let!(:service_provider)    { FactoryGirl.create(:service_provider, organization_id: program.id, identity_id: jug2.id)}
  let!(:super_user)          { FactoryGirl.create(:super_user, organization_id: program.id, identity_id: jpl6.id)}
  let!(:catalog_manager)     { FactoryGirl.create(:catalog_manager, organization_id: program.id, identity_id: jpl6.id) }
  let!(:clinical_provider)   { FactoryGirl.create(:clinical_provider, organization_id: program.id, identity_id: jug2.id) }
  let!(:available_status)    { FactoryGirl.create(:available_status, organization_id: program.id, status: 'submitted')}
  let!(:available_status2)   { FactoryGirl.create(:available_status, organization_id: program.id, status: 'draft')}
  let!(:subsidy)             { FactoryGirl.create(:subsidy, pi_contribution: 2500, sub_service_request_id: sub_service_request.id)}
  let!(:subsidy_map)         { FactoryGirl.create(:subsidy_map, organization_id: program.id) }
end

def build_service_request
  let!(:service_request)     { FactoryGirl.create(:service_request, status: "draft") }
  let!(:institution)         { FactoryGirl.create(:institution,name: 'Medical University of South Carolina', order: 1, abbreviation: 'MUSC', is_available: 1)}
  let!(:provider)            { FactoryGirl.create(:provider,parent_id:institution.id,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider', abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program)             { FactoryGirl.create(:program,type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1, abbreviation:'Informatics', process_ssrs:  0, is_available: 1, show_in_cwf: true, position_in_cwf: 6)}
  let!(:core)                { FactoryGirl.create(:core, parent_id: program.id)}
  let!(:core_17)             { FactoryGirl.create(:core, parent_id: program.id, abbreviation: "Nutrition", show_in_cwf: true, position_in_cwf: 4) }
  let!(:core_13)             { FactoryGirl.create(:core, parent_id: program.id, abbreviation: "Nursing", show_in_cwf: true, position_in_cwf: 1) }
  let!(:core_16)             { FactoryGirl.create(:core, parent_id: program.id, abbreviation: "Lab and Biorepository", show_in_cwf: true, position_in_cwf: 2) }
  let!(:core_15)             { FactoryGirl.create(:core, parent_id: program.id, abbreviation: "Imaging", show_in_cwf: true, position_in_cwf: 3) }
  let!(:core_62)             { FactoryGirl.create(:core, parent_id: program.id, abbreviation: "PWF Services", show_in_cwf: true, position_in_cwf: 5) }
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, ssr_id: "0001", service_request_id: service_request.id, organization_id: program.id,status: "draft")}


  before :each do
    program.tag_list.add("ctrc")
    program.save
    service_request.update_attribute(:service_requester_id, Identity.find_by_ldap_uid("jug2").id)
  end
end

def add_visits
  create_visits
  update_visits
  update_visit_groups
end

def create_visits
  service_request.reload
  visit_names = ["I'm", "a", 'little', 'teapot', 'short', 'and', 'stout', 'visit', 'me', 'please']
  service_request.arms.each do |arm|
    service_request.per_patient_per_visit_line_items.each do |line_item|
      arm.create_line_items_visit(line_item)
    end
  end
  arm1.reload
  arm2.reload
end

def update_visits
  service_request.arms.each do |arm|
    arm.visits.each do |visit|
      visit.update_attributes(quantity: 15, research_billing_qty: 5, insurance_billing_qty: 5, effort_billing_qty: 5, billing: Faker::Lorem.word)
    end
  end
end

def update_visit_groups
  service_request.arms.each do |arm|
    arm.visit_groups.each do |vg|
      vg.update_attributes(day: vg.position)
    end
  end
end

def build_arms
  let!(:protocol_for_service_request_id) {project.id rescue study.id}
  let!(:arm1)                { FactoryGirl.create(:arm, name: "Arm", protocol_id: protocol_for_service_request_id, visit_count: 10, subject_count: 2)}
  let!(:arm2)                { FactoryGirl.create(:arm, name: "Arm2", protocol_id: protocol_for_service_request_id, visit_count: 5, subject_count: 4)}
  # let!(:visit_group)         { FactoryGirl.create(:visit_group, arm_id: arm1.id, position: 1, day: 1)}
end

def build_project
  let!(:project) {
    protocol = Project.create(FactoryGirl.attributes_for(:protocol))
    protocol.update_attributes(:funding_status => "funded", :funding_source => "federal", :indirect_cost_rate => 50.0, start_date: Time.now, end_date: Time.now + 2.month)
    protocol.save :validate => false
    identity = Identity.find_by_ldap_uid('jug2')
    FactoryGirl.create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity.id,
        project_rights:  "approve",
        role:            "primary-pi")
    identity2 = Identity.find_by_ldap_uid('jpl6@musc.edu')
    FactoryGirl.create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity2.id,
        project_rights:  "approve",
        role:            "business-grants-manager")
    service_request.update_attribute(:protocol_id, protocol.id)
    protocol.reload
    service_request.reload
    protocol
  }
end

def build_study
  let!(:study) {
    protocol = Study.create(FactoryGirl.attributes_for(:protocol))
    protocol.update_attributes(:funding_status => "funded", :funding_source => "federal", :indirect_cost_rate => 50.0, start_date: Time.now, end_date: Time.now + 2.month)
    protocol.save :validate => false
    identity = Identity.find_by_ldap_uid('jug2')
    FactoryGirl.create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity.id,
        project_rights:  "approve",
        role:            "primary-pi")
    identity2 = Identity.find_by_ldap_uid('jpl6@musc.edu')
    FactoryGirl.create(
        :project_role,
        protocol_id:     protocol.id,
        identity_id:     identity2.id,
        project_rights:  "approve",
        role:            "business-grants-manager")
    service_request.update_attribute(:protocol_id, protocol.id)
    protocol.reload
    protocol
  }
end

def build_clinical_data all_subjects = nil
  service_request.arms.each do |arm|
    arm.populate_subjects
  end
end

def build_fake_notification
  let!(:sender) {FactoryGirl.create(:identity, last_name:'Glenn2', first_name:'Julia2', ldap_uid:'jug3', institution:'medical_university_of_south_carolina', college:'college_of_medecine', department:'other', email:'glennj2@musc.edu', credentials:'BS,    MRA', catalog_overlord: true, password:'p4ssword', password_confirmation:'p4ssword', approved: true)}
  let!(:notification) {FactoryGirl.create(:notification, sub_service_request_id: sub_service_request.id, originator_id: sender.id)}
  let!(:message) {FactoryGirl.create(:message, notification_id: notification.id, to: jug2.id, from: sender.id, email: "test@test.org", subject: "test message", body: "This is a test, and only a test")}
  let!(:user_notification) {FactoryGirl.create(:user_notification, identity_id: jug2.id, notification_id: notification.id, read: false)}
end

