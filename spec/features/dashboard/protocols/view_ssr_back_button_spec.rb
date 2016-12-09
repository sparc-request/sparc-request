require 'rails_helper'

RSpec.describe 'view SSR back button', js: true do

  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @protocol        = create(:protocol_federally_funded,
                              primary_pi: jug2,
                              start_date: "2016-01-01",
                              end_date: "2016-01-30",
                              type: 'Study')
    @organization    = create(:organization)
    @service_request = create(:service_request_without_validations,
                              protocol: @protocol,
                              status: 'draft')
    @ssr             = create(:sub_service_request,
                              service_request: @service_request,
                              organization: @organization,
                              status: 'submitted')
    @service         = create(:service, organization: @organization)
    @line_item       = create(:line_item,
                              sub_service_request: @ssr,
                              service_request: @service_request,
                              service: @service)

  end

  context 'click view from requests modal' do
    scenario 'sees the back button' do
      visit dashboard_root_path
      wait_for_javascript_to_finish
      click_button 'Requests'
      wait_for_javascript_to_finish
      click_button 'View'
      wait_for_javascript_to_finish

      expect(page).to have_selector('.view-ssr-back-button')
    end

    context 'and clicks the back button' do
      scenario 'sees the requests modal' do

      visit dashboard_root_path
      wait_for_javascript_to_finish
      click_button 'Requests'
      wait_for_javascript_to_finish
      click_button 'View'
      wait_for_javascript_to_finish
      click_button 'Back'
      wait_for_javascript_to_finish

      expect(page).to have_selector(".modal-title", text: "#{@protocol.short_title}")
      end
    end

  end

  context 'click view from protocols/show page' do
    scenario 'does not see the back button' do
      visit dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish
      click_button 'View'
      wait_for_javascript_to_finish

      expect(page).to_not have_selector('.view-ssr-back-button')
    end
  end

end
