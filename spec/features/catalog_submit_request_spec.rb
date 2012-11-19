require 'spec_helper'

feature 'as a user on catalog page' do
  it 'Submit Request', :js => true do
    # puts Identity.all.inspect
    # login(identity)
    visit root_path
    click_link("Click here to proceed with your institutional login")
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    sleep(3)
    click_link("Office of Biomedical Informatics")
    sleep(3)
    click_button("Add")
    sleep(3)
    find(:xpath, "//a/img[@alt='Submit_request']/..").click
    #save_and_open_page
  end

end