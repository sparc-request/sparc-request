require 'rails_helper'

RSpec.describe 'user archives a protocol', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    visit portal_root_path
    wait_for_javascript_to_finish
  end

  describe 'clicking the archive button' do
    it "should hide the protocol" do
      protocol_id = Protocol.first.id
      within ".protocol-information-#{protocol_id}" do
        find('.protocol-archive-button').click
      end
      wait_for_javascript_to_finish
      expect(page).to_not have_css("#blue-provider-#{protocol_id}")
      expect(page).to_not have_css(".protocol-information-#{protocol_id}")
    end
  end
end