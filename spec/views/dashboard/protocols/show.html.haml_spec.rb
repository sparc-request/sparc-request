require 'rails_helper'

RSpec.describe 'dashboard/protocols/show', type: :view do
  let_there_be_lane

  let!(:protocol) do
    protocol = build(:protocol_federally_funded,
      :without_validations,
      primary_pi: jug2,
      type: 'Study',
      archived: false,
      short_title: 'My Awesome Short Title')
    assign(:protocol, protocol)
    protocol
  end

  let!(:protocol_role) do
    protocol_role = instance_double('ProjectRole',
      'can_edit?' => true)
    assign(:protocol_role, protocol_role)
    protocol_role
  end

  before(:each) do
    assign(:user, jug2)
    assign(:protocol_type, 'Study')
    assign(:permission_to_edit, false)
    
    render
  end

  it 'should render dashboard/protocols/summary' do
    expect(response).to render_template(partial: 'dashboard/protocols/_summary',
      locals: {
        protocol: protocol,
        protocol_role: protocol_role,
        protocol_type: 'Study'
      })
  end

  it 'should render dashboard/associated_users/table' do
    expect(response).to render_template(partial: 'dashboard/associated_users/_table',
      locals: { protocol: protocol })
  end

  it 'should render dashboard/service_requests/service_requests' do
    expect(response).to render_template(partial: 'dashboard/service_requests/service_requests',
      locals: { protocol: protocol, permission_to_edit: false })
  end
end
