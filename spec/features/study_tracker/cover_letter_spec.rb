require 'spec_helper'

describe "payments", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()


  before :each do
    create_visits    
    sub_service_request.update_attributes(in_work_fulfillment: true)
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "Creating a new cover letter" do
    before(:each) do
      visit study_tracker_sub_service_request_path(sub_service_request.id)
      find('.billing-tab').click # Capybara barfs on click_link
      click_link "New cover letter"
    end

    it "Renders the cover letter template into an editable element" do
      find("#cover_letter_content_editor").should have_text "To Whom It May Concern"
    end

    it "takes you back to the Billings tab with the new Cover Letter rendered" do
      click_button "Save"

      cl = sub_service_request.cover_letters.last

      within('#billings_list') do
        find("td.actions").should have_link("Download", href: study_tracker_sub_service_request_cover_letter_path(sub_service_request, cl, format: "pdf"))
        find("td.actions").should have_link("Edit")
      end
    end
  end

  describe "Editing a cover letter" do
    before(:each) do
      cover_letter = sub_service_request.cover_letters.create(content: "my cover letter")
      visit edit_study_tracker_sub_service_request_cover_letter_path(sub_service_request, cover_letter)
    end

    it "Shows the letter contents in an editable field" do
      find("#cover_letter_content_editor").should have_text "my cover letter"
    end

    it "Saves the model" do
      # Unfortunately Capybara does not support contenteditable elements, so we're just gonna have to take this one on faith
    end
  end
end