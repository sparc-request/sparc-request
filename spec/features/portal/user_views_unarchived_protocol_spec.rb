require 'rails_helper'

RSpec.describe 'user views unarchived protocols', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    create(:protocol_without_validations, archived: true)
    visit portal_root_path
  end

  describe 'visit portal root page' do

    context "before clicking the 'Show Archived Protocols' button" do

      it "should not show archived protocols " do
        expect(page).to_not have_css("#blue-provider")
        expect(page).to_not have_css(".protocol-information")
      end
    end

    context "after clicking the 'Show Archived Protocols' button" do

      it 'should show archived protocols' do
        wait_for_javascript_to_finish
        find('.archive_button').click

        expect(page).to have_css(".blue-provider")
        expect(page).to have_css(".protocol-information")
      end
    end
  end
end
