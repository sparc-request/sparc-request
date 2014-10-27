# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'spec_helper'

feature 'create new service' do
  background do
    default_catalog_manager_setup
  end
  
  scenario 'create new service under a program', :js => true do
    program = Program.find_by_name 'Office of Biomedical Informatics'
    within("#PROGRAM#{program.id} > ul > li:nth-of-type(2)") do
      click_link('Create New Service')
    end    

    # Program Select should defalut to parent Program
    within('#service_program') do
      page.should have_content('Office of Biomedical Informatics')
    end

    # Core Select should default to None
    within('#service_core') do
      page.should have_content('None')
    end
  
    fill_in 'service_name', :with => 'Test Service'
    fill_in 'service_abbreviation', :with => 'TestService'
    fill_in 'service_order', :with => '1'
    fill_in 'service_description', :with => 'Description'
    
    ## Create a Pricing Map
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button('Add Pricing Map')
    
    within('.ui-accordion') do
      page.execute_script %Q{ $('.ui-accordion-header:last').click() }
      page.execute_script %Q{ $('.pricing_map_display_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      page.execute_script %Q{ $('.pricing_map_effective_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      fill_in "pricing_maps_blank_pricing_map_full_rate", :with => 4321
      fill_in "clinical_quantity_", :with => "Each"
      wait_for_javascript_to_finish
      find('#unit_factor_', visible: true).click
      wait_for_javascript_to_finish
    end    

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'Test Service created successfully' )
  end

  scenario 'create new service under a core', :js => true do
    core = Core.find_by_name 'Clinical Data Warehouse'
    within("#CORE#{core.id} > ul > li:nth-of-type(1)") do
      click_link('Create New Service')
    end    

    # Program Select should defalut to parent Program
    within('#service_program') do
      page.should have_content('Office of Biomedical Informatics')
    end

    # Core Select should default to parent Core
    within('#service_core') do
      page.should have_content('Clinical Data Warehouse')
    end
  
    fill_in 'service_name', :with => 'Core Test Service'
    fill_in 'service_abbreviation', :with => 'CoreTestService'
    fill_in 'service_order', :with => '1'
    fill_in 'service_description', :with => 'Description'
    
    ## Create a Pricing Map
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button('Add Pricing Map')
    
    within('.ui-accordion') do
      page.execute_script %Q{ $('.ui-accordion-header:last').click() }
      page.execute_script %Q{ $('.pricing_map_display_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      page.execute_script %Q{ $('.pricing_map_effective_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      fill_in "pricing_maps_blank_pricing_map_full_rate", :with => 4321
      fill_in "clinical_quantity_", :with => "Each"
      wait_for_javascript_to_finish
      find('#unit_factor_', visible: true).click
      wait_for_javascript_to_finish
    end      

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'Core Test Service created successfully' )
  end
  
  scenario ':user only with access to this core can see link for: Create New Service', :js => true do   
    identity = Identity.create(last_name: 'Miller', first_name: 'Robert', ldap_uid: 'rmiller@musc.edu', email:  'rmiller@musc.edu', password: 'p4ssword',password_confirmation: 'p4ssword',  approved: true )
    identity.save!

    core = Core.find_by_name('Clinical Data Warehouse')
    
    cm = CatalogManager.create( organization_id: core.id, identity_id: identity.id, )
    cm.save!

    login_as(Identity.find_by_ldap_uid('rmiller@musc.edu'))
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    expect(page).to have_content('Create New Service')
  end
  
  scenario 'create new service under a program does NOT display an error message because a pricing setup has been created at the provider level', :js => true do
    program = Program.find_by_name 'Office of Biomedical Informatics'
    
    pricing_setup = PricingSetup.where(:organization_id => program.id).first 
    pricing_setup.destroy
    
    pricing_setup = FactoryGirl.create(:pricing_setup, organization_id: program.provider.id, display_date: Date.today, effective_date: Date.today,
      college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type:'full', internal_rate_type: 'full')
    pricing_setup.save!
    
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#PROGRAM#{program.id} > ul > li:nth-of-type(2)") do
      click_link('Create New Service')
    end    

    # Program Select should default to parent Program
    within('#service_program') do
      page.should have_content('Office of Biomedical Informatics')
    end
  end
  
  scenario 'create new service under a core does NOT display an error message because a pricing setup has been created at the provider level', :js => true do
    core = Core.find_by_name 'Clinical Data Warehouse'
    
    pricing_setup = PricingSetup.where(:organization_id => core.program.id).first 
    pricing_setup.destroy
    
    pricing_setup = FactoryGirl.create(:pricing_setup, organization_id: core.program.provider.id, display_date: Date.today, effective_date: Date.today,
      college_rate_type: 'full', federal_rate_type: 'full', foundation_rate_type: 'full', industry_rate_type: 'full', investigator_rate_type:'full', internal_rate_type: 'full')
    pricing_setup.save!
    
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#CORE#{core.id} > ul > li:nth-of-type(1)") do
      click_link('Create New Service')
    end    

    # Program Select should default to parent Program
    within('#service_program') do
      page.should have_content('Office of Biomedical Informatics')
    end
  end
  
  scenario 'create new service under a program displays errors message because a service provider has not been set', :js => true do
    program = Program.find_by_name 'Office of Biomedical Informatics'
    service_provider = ServiceProvider.where(:organization_id => program.provider.id).first 
    service_provider.destroy
    
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#PROGRAM#{program.id} > ul > li:nth-of-type(2)") do
      click_link('Create New Service')
    end    

    get_alert_window do |prompt|
      expect(prompt.text).to  eq("There needs to be at least one service provider on a parent organization to create a new service. ")
      prompt.accept
    end
  end
  
  scenario 'create new service under a program displays errors message because program\'s pricing setup is empty', :js => true do
    program = Program.find_by_name 'Office of Biomedical Informatics'
    pricing_setup = PricingSetup.where(:organization_id => program.id).first 
    pricing_setup.destroy
    
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#PROGRAM#{program.id} > ul > li:nth-of-type(2)") do
      click_link('Create New Service')
    end    

    get_alert_window do |prompt|
      expect(prompt.text).to  eq("Before creating services, please configure an active pricing setup for either the program '"<< program.name << "' or the provider '" << program.provider.name << "'.")
      prompt.accept
    end
  end
  
  scenario 'create new service under a program displays two error messages because program\'s pricing setup and service provider are both empty', :js => true do
    program = Program.find_by_name 'Office of Biomedical Informatics'
    pricing_setup = PricingSetup.where(:organization_id => program.id).first 
    pricing_setup.destroy
    
    service_provider = ServiceProvider.where(:organization_id => program.provider.id).first 
    service_provider.destroy
    
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#PROGRAM#{program.id} > ul > li:nth-of-type(2)") do
      click_link('Create New Service')
    end    

    get_alert_window do |prompt|
      expect(prompt.text).to  eq("There needs to be at least one service provider on a parent organization to create a new service. Before creating services, please configure an active pricing setup for either the program '"<< program.name << "' or the provider '" << program.provider.name << "'.")
      prompt.accept
    end
  end
  

  scenario 'create new service under a core displays errors message because because a service provider has not been set', :js => true do
    core = Core.find_by_name 'Clinical Data Warehouse'
    
    service_provider = ServiceProvider.where(:organization_id => core.program.provider.id).first 
    service_provider.destroy
    
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#CORE#{core.id} > ul > li:nth-of-type(1)") do
      click_link('Create New Service')
    end    

    get_alert_window do |prompt|
      expect(prompt.text).to  eq("There needs to be at least one service provider on a parent organization to create a new service. ")
      prompt.accept
    end
  end
  
  scenario 'create new service under a core displays errors message because program\'s pricing setup is empty', :js => true do
    core = Core.find_by_name 'Clinical Data Warehouse'
    
    pricing_setup = PricingSetup.where(:organization_id => core.program.id).first 
    pricing_setup.destroy
    
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#CORE#{core.id} > ul > li:nth-of-type(1)") do
      click_link('Create New Service')
    end    

    get_alert_window do |prompt|
      expect(prompt.text).to  eq("Before creating services, please configure an active pricing setup for either the program '"<< core.program.name << "' or the provider '" << core.program.provider.name << "'.")
      prompt.accept
    end
  end
  
  scenario 'create new service under a core displays two error messages because program\'s pricing setup and service provider are both empty', :js => true do
    core = Core.find_by_name 'Clinical Data Warehouse'
    
    pricing_setup = PricingSetup.where(:organization_id => core.program.id).first 
    pricing_setup.destroy
    
    service_provider = ServiceProvider.where(:organization_id => core.program.provider.id).first 
    service_provider.destroy
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    
    within("#CORE#{core.id} > ul > li:nth-of-type(1)") do
      click_link('Create New Service')
    end    

    get_alert_window do |prompt|
      expect(prompt.text).to  eq("There needs to be at least one service provider on a parent organization to create a new service. Before creating services, please configure an active pricing setup for either the program '"<< core.program.name << "' or the provider '" << core.program.provider.name << "'.")
      prompt.accept
    end
  end
end 