require 'rails_helper'

RSpec.describe 'layouts/dashboard/_dashboard_header.html.haml', view: true do
  let_there_be_lane

  it 'should display number of unread notifications (for user)' do
    other_user = create(:identity, first_name: 'Santa', last_name: 'Claws')
    note = create(:notification, other_user_id: jug2.id,
      originator_id: other_user.id, subject: 'notification 1',
      body: 'message 1', read_by_originator: false, read_by_other_user: false)
    note = create(:notification, other_user_id: jug2.id,
      originator_id: other_user.id, subject: 'notification 1',
      body: 'message 1', read_by_originator: false, read_by_other_user: false)
    note = create(:notification, other_user_id: jug2.id,
      originator_id: other_user.id, subject: 'notification 1',
      body: 'message 1', read_by_originator: false, read_by_other_user: true)

    session[:breadcrumbs] = Dashboard::Breadcrumber.new
    render 'layouts/dashboard/dashboard_header', user: jug2

    expect(response).to have_selector('button#messages-btn', text: '2')
  end
end
