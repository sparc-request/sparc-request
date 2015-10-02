require 'rails_helper'

RSpec.describe 'user views unarchived protocols', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let!(:protocol) { create(:protocol_without_validations, archived: true) }

  before :each do
    visit portal_root_path
    wait_for_javascript_to_finish
  end

  describe 'visit portal root page' do
    it "should not show archived protocols " do
      expect(page).to_not have_css(".protocol-information-#{protocol.id}")
    end
  end
end