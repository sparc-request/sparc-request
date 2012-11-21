require 'spec_helper'

feature 'as a user on catalog page' do
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