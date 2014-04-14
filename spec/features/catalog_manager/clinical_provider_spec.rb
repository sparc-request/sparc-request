require 'spec_helper'

feature 'clinical providers' do
  background do
    default_catalog_manager_setup
  end 
  
  scenario 'user adds and a clinical provider from an organization', :js => true do
    add_clinical_provider

    within "#cp_info" do
      page.should have_text("Julia Glenn (glennj@musc.edu)")
      find("img.cp_delete").click
    end

    a = page.driver.browser.switch_to.alert
    a.text.should eq "Are you sure you want to remove this Clinical Provider?"
    a.accept

    within "#cp_info" do
      page.should_not have_text("Julia Glenn")
    end
  end
end


def add_clinical_provider
  wait_for_javascript_to_finish
  click_link('Office of Biomedical Informatics')
  within '#cwf_fieldset' do
    find('.legend').click
    wait_for_javascript_to_finish
  end
  sleep 3
  fill_in "new_cp", :with => "Julia"
  wait_for_javascript_to_finish
  page.find('a', :text => "Julia Glenn", :visible => true).click()
  wait_for_javascript_to_finish
end
