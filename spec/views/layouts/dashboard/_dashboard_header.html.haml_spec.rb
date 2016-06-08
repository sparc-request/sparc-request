require 'rails_helper'

RSpec.describe 'layouts/dashboard/_dashboard_header.html.haml', view: true do
  include RSpecHtmlMatchers

  before(:each) do
    @user = instance_double(Identity,
      ldap_uid: 'jug2',
      email: 'user@email.com',
      unread_notification_count: 2,
      )

    session[:breadcrumbs] = Dashboard::Breadcrumber.new
    expect(session[:breadcrumbs]).to receive(:breadcrumbs).and_return('All those other pages.')
  end

  it 'should display view epic queue button' do
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_selector('button#epic-queue-btn', text: 'View Epic Queue')
  end

  it 'should display number of unread notifications (for user)' do
    @show_messages = true
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_selector('button#messages-btn span.badge', text: '2')
  end

  it 'should display breadcrumbs by sending :breadcrumbs to session[:breadcrumbs]' do
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_content('All those other pages.')
  end

  it 'should display welcome message to user' do
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_content(t(:dashboard)[:navbar][:logged_in_as] + "user@email.com")
    expect(response).to have_tag('a', text: "Logout")
  end
end
