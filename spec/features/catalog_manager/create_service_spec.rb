# require 'spec_helper'

# feature 'create new service' do
#   background do
#     default_catalog_manager_setup
#   end
  
#   scenario 'create new service under a program', :js => true do
#     program = Program.find_by_name 'Office of Biomedical Informatics'
#     within ("#PROGRAM#{program.id} > ul > li:nth-of-type(2)") do
#       click_link('Create New Service')
#     end    

#     # Program Select should defalut to parent Program
#     within ('#service_program') do
#       page.should have_content('Office of Biomedical Informatics')
#     end

#     # Core Select should default to None
#     within ('#service_core') do
#       page.should have_content('None')
#     end
  
#     fill_in 'service_name', :with => 'Test Service'
#     fill_in 'service_abbreviation', :with => 'TestService'
#     fill_in 'service_order', :with => '1'
#     fill_in 'service_description', :with => ''

#     page.execute_script("$('#save_button').click();")
#     page.should have_content( 'New service created!' )
#   end

#   scenario 'create new service under a core', :js => true do
#     core = Core.find_by_name 'Clinical Data Warehouse'
#     within ("#CORE#{core.id} > ul > li:nth-of-type(1)") do
#       click_link('Create New Service')
#     end    

#     # Program Select should defalut to parent Program
#     within ('#service_program') do
#       page.should have_content('Office of Biomedical Informatics')
#     end

#     # Core Select should default to parent Core
#     within ('#service_core') do
#       page.should have_content('Clinical Data Warehouse')
#     end
  
#     fill_in 'service_name', :with => 'Core Test Service'
#     fill_in 'service_abbreviation', :with => 'CoreTestService'
#     fill_in 'service_order', :with => '1'
#     fill_in 'service_description', :with => ''

#     page.execute_script("$('#save_button').click();")
#     page.should have_content( 'New service created!' )
#   end

# end