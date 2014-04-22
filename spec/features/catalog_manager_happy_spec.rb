require 'spec_helper'
include CapybaraCatalogManager

describe 'Catalog Manager' do
  let_there_be_lane
  fake_login_for_each_test

  it 'Should create a functional catalog', :js => true do
    visit catalog_manager_root_path

    create_new_institution 'someInst'
    create_new_provider 'someProv', 'someInst'
    create_new_program 'someProg', 'someProv'
    create_new_core 'someCore', 'someProg'
    create_new_service 'someService', 'someCore', :otf => false
    create_new_service 'someService2', 'someCore', :otf => true

    create_new_institution 'Medical University of South Carolina', {:abbreviation => 'MUSC'}
    create_new_provider 'South Carolina Clinical and Translational Institute (SCTR)', 'Medical University of South Carolina', {:abbreviation => 'SCTR1'}
    create_new_program 'Office of Biomedical Informatics', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics'}
    create_new_program 'Clinical and Translational Research Center (CTRC)', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics'}
    create_new_core 'Clinical Data Warehouse', 'Office of Biomedical Informatics'
    create_new_core 'Nursing Services', 'Clinical and Translational Research Center (CTRC)'
    create_new_service 'MUSC Research Data Request (CDW)', 'Clinical Data Warehouse', {:otf => true, :unit_type => 'Per Query', :unit_factor => 1, :rate => '2.00', :unit_minimum => 1}
    create_new_service 'Breast Milk Collection', 'Nursing Services', {:otf => false, :unit_type => 'Per patient/visit', :unit_factor => 1, :rate => '6.36', :unit_minimum => 1}

    create_new_service 'SuperService 1', 'Office of Biomedical Informatics',{:otf => false, :rate => '500000.00', :unit_minimum => 5}
    create_new_service 'SuperService 2', 'Clinical and Translational Research Center (CTRC)',{:otf => true, :rate => '500000.00', :unit_minimum => 5}
    
    create_new_institution 'invisibleInstitution', :is_available => false
    create_new_institution 'Institute of Invisibility'
    create_new_provider 'invisibleProv', 'Institute of Invisibility', :is_available => false
    create_new_provider 'Provider of Invisibility', 'Institute of Invisibility'
    create_new_program 'invisibleProg', 'Provider of Invisibility', :is_available => false
    create_new_program 'Program of Invisibility','Provider of Invisibility'
    create_new_core 'invisibleCore','Program of Invisibility', :is_available => false
    create_new_core 'Core of Invisibility','Program of Invisibility'
    create_new_service 'invisibleService', 'Core of Invisibility', :is_available => false
    create_new_service 'Service of Visibility','Core of Invisibility'



    visit root_path
    #sleep 30

    click_link("Medical University of South Carolina")
    wait_for_javascript_to_finish
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    wait_for_javascript_to_finish
    click_link("Office of Biomedical Informatics")
    wait_for_javascript_to_finish
    page.should have_xpath("//a[text()='MUSC Research Data Request (CDW)']")
    page.should have_xpath("//a[text()='SuperService 1']")
    click_link("Clinical and Translational Research Center (CTRC)")
    wait_for_javascript_to_finish
    page.should have_xpath("//a[text()='SuperService 2']")
    page.should have_xpath("//a[text()='Breast Milk Collection']")
    click_link("Medical University of South Carolina")

    page.should_not have_xpath("//a[text()='invisibleInstitution']")
    click_link('Institute of Invisibility')
    page.should_not have_xpath("//a[text()='invisibleProv']")
    click_link('Provider of Invisibility')
    page.should_not have_xpath("//a[text()='invisibleProg']")
    click_link('Program of Invisibility')
    page.should_not have_xpath("//a[text()='invisibleCore']")
    click_link('Core of Invisibility')
    page.should_not have_xpath("//a[text()='invisibleService']")
    page.should have_xpath("//a[text()='Service of Visibility']")
    #sleep 120
  end  
end
