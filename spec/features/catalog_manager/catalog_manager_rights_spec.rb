require 'spec_helper'

feature 'catalog managers' do
  background do
    default_catalog_manager_setup
  end 
  
  scenario 'user adds a new catalog manager to institution', :js => true do
    add_catalog_manager

    within "#cm_info" do
      page.should have_text("Jason Leonard (leonarjp@musc.edu)")
    end
  end

  scenario 'user deletes a catalog manager from institution', :js => true do
    add_catalog_manager
    within "#cm_info" do
      page.all("img.cm_delete")[1].click
    end

    a = page.driver.browser.switch_to.alert
    a.text.should eq "Are you sure you want to remove rights for this user from the Catalog Manager?"
    a.accept
    
    within "#cm_info" do
      page.should_not have_text("Jason Leonard")
    end
  end
  
end


def add_catalog_manager
  click_link('Medical University of South Carolina')
  fill_in "new_cm", :with => "leonarjp"
  wait_for_javascript_to_finish
  page.find('a', :text => "Jason Leonard", :visible => true).click()
  wait_for_javascript_to_finish
end