require 'spec_helper'
include CapybaraCatalogManager
include CapybaraProper


describe 'A Happy Test' do
  let_there_be_lane
  fake_login_for_each_test

  it 'should make you feel happy', :js => true do
    visit catalog_manager_root_path

    create_new_institution 'invisibleInstitution', :is_available => false
    create_new_institution 'Institute of Invisibility', :order =>2
    create_new_provider 'invisibleProv', 'Institute of Invisibility', :is_available => false
    create_new_provider 'Provider of Invisibility', 'Institute of Invisibility'
    create_new_program 'invisibleProg', 'Provider of Invisibility', :is_available => false
    create_new_program 'Program of Invisibility','Provider of Invisibility'
    create_new_core 'invisibleCore','Program of Invisibility', :is_available => false
    create_new_core 'Core of Invisibility','Program of Invisibility'
    create_new_service 'invisibleService', 'Core of Invisibility', :is_available => false
    create_new_service 'Service of Visibility','Core of Invisibility'
    create_new_service 'Linked Service of Visibility','Core of Invisibility',:linked => {:on? => true, :service => 'Service of Visibility', :required? => true, :quantity? => true, :quantityNum => 5}

    create_new_institution 'Medical University of South Carolina', {:abbreviation => 'MUSC'}
    create_new_provider 'South Carolina Clinical and Translational Institute (SCTR)', 'Medical University of South Carolina', {:abbreviation => 'SCTR1'}
    create_new_program 'Office of Biomedical Informatics', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics'}
    create_new_program 'Clinical and Translational Research Center (CTRC)', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics'}
    create_new_core 'Clinical Data Warehouse', 'Office of Biomedical Informatics'
    create_new_core 'Nursing Services', 'Clinical and Translational Research Center (CTRC)'
    create_new_service 'MUSC Research Data Request (CDW)', 'Clinical Data Warehouse', {:otf => true, :unit_type => 'Per Query', :unit_factor => 1, :rate => '2.00', :unit_minimum => 1}
    create_new_service 'Breast Milk Collection', 'Nursing Services', {:otf => false, :unit_type => 'Per patient/visit', :unit_factor => 1, :rate => '6.36', :unit_minimum => 1}
    visit root_path

        #**Check visibility conditions**#
    #sleep 360
    click_link('Institute of Invisibility')
    wait_for_javascript_to_finish
    page.should_not have_xpath("//a[text()='invisibleInstitution']")
    page.should_not have_xpath("//a[text()='invisibleProv']")
    click_link('Provider of Invisibility')
    wait_for_javascript_to_finish
    click_link('Program of Invisibility')#For some reason, this doesn't work
    click_link('Program of Invisibility')#If you only click it one time.
    click_link('Program of Invisibility')#Selenium issue-not sparc I believe.
    wait_for_javascript_to_finish
    page.should_not have_xpath("//a[text()='invisibleProg']")
    page.should_not have_xpath("//a[text()='invisibleCore']") 
    page.should_not have_xpath("//a[text()='invisibleService']")
    page.should have_xpath("//a[text()='Service of Visibility']")
    page.should have_xpath("//a[text()='Linked Service of Visibility']")

        #**END Check visibility conditions END**#

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

    submitServiceRequestPage (services)
    selectStudyPage
    selectDatesAndArmsPage(request)
    serviceCalendarPage(request)
    documentsPage
    reviewPage(request)
    submissionConfirmationPage
    

  end

end



