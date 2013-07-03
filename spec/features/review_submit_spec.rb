require 'spec_helper'
require 'rake'

# TODO: I want to remove the sleeps from this page, but I can't because
# when I replace then with wait_for_javascript_to_finish, I get:
#
#      Failure/Error: wait_for_javascript_to_finish
#      Selenium::WebDriver::Error::JavascriptError:
#        ReferenceError: $ is not defined

describe "review page" do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    file = File.join(Rails.root, 'surveys/system_satisfaction_survey.rb')
    Surveyor::Parser.parse_file(file, {:trace => Rake.application.options.trace})
    add_visits
    visit review_service_request_path service_request.id
  end

  describe "clicking save and exit/draft" do
    it 'Should save request as a draft', :js => true do
      find(:xpath, "//a/img[@alt='Wait_save_draft']/..").click

      # TODO: uncommenting this results in '$ is not defined', but
      # ideally we do need to wait for ajax requests to complete before
      # reading from the database
      # wait_for_javascript_to_finish

      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("draft")
    end
  end

  describe "clicking submit and declining the system satisfaction survey" do
    it 'Should submit the page', :js => true do
      find(:xpath, "//a/img[@alt='Confirm_request']/..").click
      find(:xpath, "//button/span[text()='No']/..").click
      wait_for_javascript_to_finish
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("submitted")
    end
  end
  
  describe "clicking submit and accepting the system satisfaction survey" do
    it 'Should submit the page', :js => true do
      find(:xpath, "//a/img[@alt='Confirm_request']/..").click
      find(:xpath, "//button/span[text()='Yes']/..").click
      wait_for_javascript_to_finish

      fill_in "r_1_string_value", :with => "Glenn"
      fill_in "r_2_string_value", :with => "Lane"
      select "Administration", :from => "r_3_answer_id"
      select "Academic Affairs/Provost", :from => "r_4_answer_id"

      # select Yes to next question and you should see text area for Yes
      all("#r_5_answer_id_input input").first().click
      fill_in "r_6_text_value", :with => "I love it"
      
      # select No to next question and you should see text area for No
      all("#r_5_answer_id_input input").last().click
      fill_in "r_7_text_value", :with => "I hate it"

      within(:css, "div.next_section") do
        click_button 'Submit'
      end
    end
  end

end
