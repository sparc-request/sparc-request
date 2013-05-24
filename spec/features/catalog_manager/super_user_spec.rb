require 'spec_helper'

feature 'super users' do
  background do
    default_catalog_manager_setup
  end 
  
  scenario 'user adds a new super user to institution', :js => true do
    add_super_user

    within "#su_info" do
      page.should have_text("Julia Glenn (glennj@musc.edu)")
    end
  end

  scenario 'user deletes a super user from institution', :js => true do
    add_super_user

    within "#su_info" do
      find("img.su_delete").click
    end

    a = page.driver.browser.switch_to.alert
    a.text.should eq "Are you sure you want to remove this Super User?"
    a.accept

    within "#su_info" do
      page.should_not have_text("Julia Glenn")
    end
  end
  
end


def add_super_user
  click_link('Medical University of South Carolina')
  fill_in "new_su", :with => "Julia"
  wait_for_javascript_to_finish
  page.find('a', :text => "Julia Glenn", :visible => true).click()
  wait_for_javascript_to_finish
end