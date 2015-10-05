require 'rails_helper'

RSpec.describe 'user archives a protocol', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let(:protocol_id) { Protocol.first.id }
  before :each do
    visit portal_root_path
  end

  describe 'clicking the archive button' do

    context "while archived Protocols shouldn't be visible" do
      it "should hide the protocol" do
        when_i_click_the_archive_protocol_button
        i_should_see_the_protocols_information_hidden
      end
    end

    context "after the 'Show Archived Protocols' button is clicked" do

      it 'should not hide the Protocol' do
        given_i_have_clicked_the_show_archived_protocols_button
        when_i_click_the_archive_protocol_button
        i_should_still_see_the_protocols_information
      end

      it 'should change the button text to read "UNARCHIVE ..."' do
        given_i_have_clicked_the_show_archived_protocols_button
        when_i_click_the_archive_protocol_button
        i_should_see_the_button_text_change
      end
    end
  end

  def given_i_have_clicked_the_show_archived_protocols_button
    find('.archive_button').click
  end

  def when_i_click_the_archive_protocol_button
    find(".protocol-archive-button[data-protocol_id='#{protocol_id}']").click
  end

  def i_should_see_the_protocols_information_hidden
    expect(page).to_not have_css("#blue-provider-#{protocol_id}")
    expect(page).to_not have_css(".protocol-information-#{protocol_id}")
  end

  def i_should_still_see_the_protocols_information
    expect(page).to have_css("#blue-provider-#{protocol_id}")
    expect(page).to have_css(".protocol-information-#{protocol_id}")
  end

  def i_should_see_the_button_text_change
    expect(page).to have_css(".protocol-archive-button[data-protocol_id='#{protocol_id}']", text: /UNARCHIVE/)
  end
end
