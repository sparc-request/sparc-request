require 'spec_helper'
include CapybaraProper


describe 'A Happy Test' do
  let_there_be_lane
  fake_login_for_each_test


  let!(:institution)  {FactoryGirl.create(:institution,id: 53,name: 'Medical University of South Carolina', order: 1,abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {FactoryGirl.create(:provider,id: 10,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',parent_id: institution.id,abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program) {FactoryGirl.create(:program,id:54,type:'Program',name:'Office of Biomedical Informatics',order:1,parent_id:provider.id,abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:program2) {FactoryGirl.create(:program,id:5,type:'Program',name:'Clinical and Translational Research Center (CTRC)',order:2,parent_id:provider.id,abbreviation:'Informatics',process_ssrs:0,is_available:1)}
  let!(:core) {FactoryGirl.create(:core,id:33,type:'Core',name:'Clinical Data Warehouse',order:1,parent_id:program.id,abbreviation:'Clinical Data Warehouse')}
  let!(:core2) {FactoryGirl.create(:core,id:8,type:'Core',name:'Nursing Services',abbreviation:'Nursing Services',order:1,parent_id:program2.id)}
  let!(:service) {FactoryGirl.create(:service,id:67,name:'MUSC Research Data Request (CDW)',abbreviation:'CDW',order:1,cpt_code:'',organization_id:core.id)}
  let!(:service2) {FactoryGirl.create(:service,id:16,name:'Breast Milk Collection',abbreviation:'Breast Milk Collection',order:1,cpt_code:'',organization_id:core2.id)}
  let!(:pricing_setup) { FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_setup2) { FactoryGirl.create(:pricing_setup, organization_id: program2.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map) {FactoryGirl.create(:pricing_map,service_id:service.id, unit_type: 'Per Query', unit_factor: 1, is_one_time_fee: 1, display_date: Time.now - 1.day, full_rate: 200, exclude_from_indirect_cost: 0, unit_minimum:1)}
  let!(:pricing_map2) {FactoryGirl.create(:pricing_map, service_id: service2.id, unit_type: 'Per patient/visit', unit_factor: 1, is_one_time_fee: 0, display_date: Time.now - 1.day, full_rate: 636, exclude_from_indirect_cost: 0, unit_minimum: 1)}
  let!(:service_provider)    { FactoryGirl.create(:service_provider, organization_id: program.id, identity_id: jug2.id)}
  let!(:service_provider2)    { FactoryGirl.create(:service_provider, organization_id: program2.id, identity_id: jug2.id)}
  #let!(:pricing_map2)       { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service2.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20) }

    #after :each do
    #  wait_for_javascript_to_finish
    #end

  it 'should make you feel happy', :js => true do
    visit root_path

    service1 = ServiceWithAddress.new(
        :instit => "Medical University of South Carolina",
        :prov => "South Carolina Clinical and Translational Institute (SCTR)",
        :prog => "Office of Biomedical Informatics",
        :core => "Clinical Data Warehouse",
        :name => "MUSC Research Data Request (CDW)",
        :short => "CDW",
        :otf => true,
        :unitPrice => 2.00
        )
    service2 = ServiceWithAddress.new(
        :instit => "Medical University of South Carolina",
        :prov => "South Carolina Clinical and Translational Institute (SCTR)",
        :prog => "Clinical and Translational Research Center (CTRC)",
        :core => "Nursing Services",
        :name => 'Breast Milk Collection',
        :unitPrice => 6.36
        )
    services = [service1,service2]

    arm1 = ASingleArm.new(:name => "ARM 1",:subjects => 5,:visits => 7)
    arm2 = ASingleArm.new(:name => "ARM 2",:subjects => 5,:visits => 3)
    arms = [arm1,arm2]

    request = ServiceRequestForComparison.new(services,arms)

    submitServiceRequest (services)
    createNewStudy
    selectStudyUsers
    removeAllServices
    click_link("Save & Continue")
    wait_for_javascript_to_finish 
    enterProtocolDates
    readdServices (services)
    chooseArmPreferences(arms)
    completeTemplateTab(request)
    arm1TotalPrice,arm2TotalPrice,otfTotalPrice = completeQuantityBillingTab (request)
    documentsPage
    reviewPage(arm1TotalPrice,arm2TotalPrice,otfTotalPrice)
    submissionConfirm
    
  end

end



