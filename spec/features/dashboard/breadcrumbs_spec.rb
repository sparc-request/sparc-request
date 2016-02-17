require 'rails_helper'

RSpec.describe 'breadcrumbs', js: true do
  let_there_be_lane
  fake_login_for_each_test
  let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, short_title: 'abc', short_title: 'Short Title') }
  let!(:ssr) do
    sr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
    create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization, admin: jug2, type: 'Institution', abbreviation: 'Organists'), status: 'draft')
  end
  let!(:paths) do
    { dashboard: '/dashboard/protocols',
      protocol: "/dashboard/protocols/#{protocol.id}",
      ssr: "/dashboard/sub_service_requests/#{ssr.id}",
      notifications: '/dashboard/notifications' }.freeze
  end

  def click_dashboard_breadcrumb
    find('#breadcrumbs a', text: 'Dashboard').click
    wait_for_javascript_to_finish
    expect(URI.parse(current_url).path).to eq paths[:dashboard]
  end

  def click_protocol_breadcrumb
    find('#breadcrumbs a', text: 'Short Title').click
    wait_for_javascript_to_finish
    expect(URI.parse(current_url).path).to eq paths[:protocol]
  end

  def click_ssr_breadcrumb
    find('#breadcrumbs a', text: 'Organists').click
    wait_for_javascript_to_finish
    expect(URI.parse(current_url).path).to eq paths[:ssr]
  end

  def click_notifications_button
    find('#messages-btn').click
    wait_for_javascript_to_finish
  end

  def click_protocol
    first('#filterrific_results tr.protocols_index_row td.id').click
    wait_for_javascript_to_finish
  end

  def click_ssr
    find('.edit_service_request', text: 'Admin Edit').click
    wait_for_javascript_to_finish
  end

  def click_requests_button_then_ssr
    first('#filterrific_results button.requests_display_link').click
    wait_for_javascript_to_finish
    find('.modal-body .edit_service_request', text: 'Admin Edit').click
    wait_for_javascript_to_finish
  end

  def check_breadcrumbs(*crumb_labels)
    crumbs = find_all('#breadcrumbs a')
    expect(crumbs.map(&:text)).to eq crumb_labels
  end

  it 'going from dashboard to protocol to dashboard' do
    visit paths[:dashboard]
    check_breadcrumbs 'Dashboard'

    click_protocol
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'
  end

  it 'going from dashboard to protocol to SubServiceRequest' do
    visit paths[:dashboard]
    check_breadcrumbs 'Dashboard'

    click_protocol
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'
  end

  it 'going from dashboard to protocol to notifications' do
    visit paths[:dashboard]
    check_breadcrumbs 'Dashboard'

    click_protocol
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Notifications'
  end

  it 'going from dashboard to SubServiceRequest to dashboard' do
    visit paths[:dashboard]
    check_breadcrumbs 'Dashboard'

    click_requests_button_then_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'
  end

  it 'going from dashboard to SubServiceRequest to protocol' do
    visit paths[:dashboard]
    check_breadcrumbs 'Dashboard'

    click_requests_button_then_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_protocol_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title'
  end

  it 'going from dashboard to SubServiceRequest to notifications' do
    visit paths[:dashboard]
    check_breadcrumbs 'Dashboard'

    click_requests_button_then_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists', 'Notifications'
  end

  it 'going from dashboard to notifications to dashboard' do
    visit paths[:dashboard]
    check_breadcrumbs 'Dashboard'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Notifications'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'
  end

  it 'going from protocol to dashboard to protocol' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_protocol
    check_breadcrumbs 'Dashboard', 'Short Title'
  end

  it 'going from protocol to dashboard to SubServiceRequest' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_requests_button_then_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'
  end

  it 'going from protocol to dashboard to notifications' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Notifications'
  end

  it 'going from protocol to SubServiceRequest to dashboard' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'
  end

  it 'going from protocol to SubServiceRequest to protocol' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_protocol_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title'
  end

  it 'going from protocol to SubServiceRequest to notifications' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_notifications_button
  end

  it 'going from protocol to notifications to dashboard' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Notifications'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'
  end

  it 'going from protocol to notifications to protocol' do
    visit paths[:protocol]
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Notifications'

    click_protocol_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title'
  end

  it 'going from SubServiceRequest to dashboard to protocol' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_protocol
    check_breadcrumbs 'Dashboard', 'Short Title'
  end

  it 'going from SubServiceRequest to dashboard to SubServiceRequest' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_requests_button_then_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'
  end

  it 'going from SubServiceRequest to dashboard to notifications' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Notifications'
  end

  it 'going from SubServiceRequest to protocol to dashboard' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_protocol_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'
  end

  it 'going from SubServiceRequest to protocol to SubServiceRequest' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_protocol_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'
  end

  it 'going from SubServiceRequest to protocol to notifications' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_protocol_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Notifications'
  end

  it 'going from SubServiceRequest to notifications to dashboard' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists', 'Notifications'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'
  end

  it 'going from SubServiceRequest to notifications to protocol' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists', 'Notifications'

    click_protocol_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title'
  end

  it 'going from SubServiceRequest to notifications to SubServiceRequest' do
    visit paths[:ssr]
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists', 'Notifications'

    click_ssr_breadcrumb
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'
  end

  it 'going from notifications to dashboard to protocol' do
    visit paths[:notifications]
    check_breadcrumbs 'Dashboard', 'Notifications'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_protocol
    check_breadcrumbs 'Dashboard', 'Short Title'
  end

  it 'going from notifications to dashboard to SubServiceRequest' do
    visit paths[:notifications]
    check_breadcrumbs 'Dashboard', 'Notifications'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_requests_button_then_ssr
    check_breadcrumbs 'Dashboard', 'Short Title', 'Organists'
  end

  it 'going from notifications to dashboard to notifications' do
    visit paths[:notifications]
    check_breadcrumbs 'Dashboard', 'Notifications'

    click_dashboard_breadcrumb
    check_breadcrumbs 'Dashboard'

    click_notifications_button
    check_breadcrumbs 'Dashboard', 'Notifications'
  end
end
