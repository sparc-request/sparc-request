require 'spec_helper'

describe "creating a new study from user portal", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test

  before :each do
    visit new_portal_protocol_path
  end
  
  after :each do
    wait_for_javascript_to_finish
  end

  describe "submitting a blank form" do

    before :each do
      find('.continue_button').click
    end

    it "should show errors" do
      page.should have_content("Short title can't be blank")
      page.should have_content("Title can't be blank")
      page.should have_content("Funding status can't be blank")
      page.should have_content("Sponsor name can't be blank")
    end

    it 'should remove errors when the form is filled in' do
      wait_for_javascript_to_finish
      fill_in "study_short_title", :with => "Bob"
      fill_in "study_title", :with => "Dole"
      fill_in "study_sponsor_name", :with => "Captain Kurt 'Hotdog' Zanzibar"
      select "Funded", :from => "study_funding_status"
      select "Federal", :from => "study_funding_source"
      find('.continue_button').click
      wait_for_javascript_to_finish
      page.should have_content "User Search"
    end
  end

  describe 'submitting a filled in form' do

    before :each do 
      fill_in "study_short_title", :with => "Bob"
      fill_in "study_title", :with => "Dole"
      fill_in "study_sponsor_name", :with => "Captain Kurt 'Hotdog' Zanzibar"
      select "Funded", :from => "study_funding_status"
      select "Federal", :from => "study_funding_source"
      find('.continue_button').click
      wait_for_javascript_to_finish
    end 

    describe 'submitting authorized users' do
      it 'should display errors if no users exist' do
        find('.continue_button').click
        page.should have_content "You must add yourself as an authorized user"
      end

      it 'should display an error if a role is not selected' do
        find('.add-authorized-user').click
        wait_for_javascript_to_finish
        page.should have_content "Role can't be blank"
      end

      it 'should return to user portal' do
        select "Primary PI", :from => "project_role_role"
        find('.add-authorized-user').click
        wait_for_javascript_to_finish
        find('.continue_button').click
        wait_for_javascript_to_finish
        page.should have_content "Bob"
      end
    end
  end


end

