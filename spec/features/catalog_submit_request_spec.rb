require 'spec_helper'

describe 'as a user on catalog page' do
  let_there_be_lane

  let!(:institution)  {FactoryGirl.create(:institution,id: 53,name: 'Medical University of South Carolina', order: 1,obisid: '87d1220c5abf9f9608121672be000412',abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {FactoryGirl.create(:provider,id: 10,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',obisid: '87d1220c5abf9f9608121672be0011ff',parent_id: institution.id,abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program) {FactoryGirl.create(:program,id:54,type:'Program',name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',parent_id:provider.id,abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:program2) {FactoryGirl.create(:program,id:5,type:'Program',name:'Clinical and Translational Research Center (CTRC)',order:2,obisid:'87d1220c5abf9f9608121672be0e3ac1',parent_id:provider.id,abbreviation:'Informatics',process_ssrs:0,is_available:1)}
  let!(:core) {FactoryGirl.create(:core,id:33,type:'Core',name:'Clinical Data Warehouse',order:1,obisid:'179eae3982ab1e4047051381fb7b1610',parent_id:program.id,abbreviation:'Clinical Data Warehouse')}
  let!(:core2) {FactoryGirl.create(:core,id:8,type:'Core',obisid:'87d1220c5abf9f9608121672be06cca0',name:'Nursing Services',abbreviation:'Nursing Services',order:1,parent_id:program2.id)}
  let!(:service) {FactoryGirl.create(:service,id:67,obisid:'87d1220c5abf9f9608121672be03867a',name:'MUSC Research Data Request (CDW)',abbreviation:'CDW',order:1,cpt_code:'',organization_id:core.id)}
  let!(:service2) {FactoryGirl.create(:service,id:16,obisid:'87d1220c5abf9f9608121672be1b4a95',name:'Breast Milk Collection',abbreviation:'Breast Milk Collection',order:1,cpt_code:'',organization_id:core2.id)}
  let!(:pricing_map) {FactoryGirl.create(:pricing_map,service_id:67,unit_type:'Per Query',unit_factor:1,is_one_time_fee:1,full_rate:0,exclude_from_indirect_cost:0,unit_minimum:1)}
  let!(:pricing_map2) {FactoryGirl.create(:pricing_map,service_id:16,unit_type:'Per patient/visit',unit_factor:1,is_one_time_fee:0,full_rate:636,exclude_from_indirect_cost: 0,unit_minimum:1)}

  it 'Submit Request', :js => true do
    # puts Identity.all.inspect
    # login(identity)

    visit root_path
    click_link("Click here to proceed with your institutional login")
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    sleep(2)
    click_link("Office of Biomedical Informatics")
    sleep(2)
    click_button("Add")
    sleep(2)
    click_link("Clinical and Translational Research Center (CTRC)")
    sleep(2)
    click_button("Add")
    sleep(2)
    find(:xpath, "//a/img[@alt='Submit_request']/..").click
    #save_and_open_page
  end

end
