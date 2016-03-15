# Most Dashboard::AssociatedUsersController actions require that the logged in
# user have certain types of ProjectRoles linking them to the Protocol to allow
# viewing and editing. This authorization is carried out by the class
# ProtocolAuthorizer, which this spec tests for the use of.
require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  let!(:identity) do
    instance_double(Identity, id: 1)
  end

  let!(:protocol) do
    obj = instance_double(Protocol,
      id: 2)
    stub_find_protocol(obj)
    obj
  end

  let!(:project_role) do
    obj = instance_double(ProjectRole,
      id: 3,
      identity: identity,
      protocol: protocol)
    stub_find_project_role(obj)
    obj
  end

  before(:each) do
    log_in_dashboard_identity(obj: identity)
  end

  context 'user does not have view privileges to Protocol' do
    render_views

    before(:each) { authorize(identity, protocol, can_view: false) }

    it 'should render authorization error on GET index and should not set @protocol' do
      get :index, protocol_id: protocol.id, format: :json

      expect(assigns(:protocol)).to be_nil
      expect(response).to render_template(partial: '_authorization_error')
    end

    it 'should render authorization error on GET show and should not set @protocol' do
      get :show, id: identity.id, protocol_id: protocol.id, format: :js

      expect(assigns(:protocol)).to be_nil
      expect(response).to render_template(partial: '_authorization_error')
    end
  end

  context 'user does not have edit privileges to Protocol' do
    render_views

    before(:each) { authorize(identity, protocol, can_edit: false) }

    it 'should render authorization error on GET edit and should not set @protocol' do
      get :edit, id: project_role.id

      expect(assigns(:protocol)).to be_nil
      expect(response).to render_template(partial: '_authorization_error')
    end

    it 'should render authorization error on GET new and should not set @protocol' do
      get :new, protocol_id: protocol.id, format: :js

      expect(assigns(:protocol)).to be_nil
      expect(response).to render_template(partial: '_authorization_error')
    end

    it 'should render authorization error on PUT create and should not set @protocol' do
      put :create, project_role: { protocol_id: protocol.id }, format: :js

      expect(assigns(:protocol)).to be_nil
      expect(response).to render_template(partial: '_authorization_error')
    end

    it 'should render authorization error on PUT update and should not set @protocol' do
      put :update, id: project_role.id, format: :js

      expect(assigns(:protocol)).to be_nil
      expect(response).to render_template(partial: '_authorization_error')
    end
  end

  def authorize(identity, protocol, opts = {})
    auth_mock = instance_double('ProtocolAuthorizer',
                                'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
                                'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
    expect(ProtocolAuthorizer).to receive(:new).
        with(protocol, identity).
        and_return(auth_mock)
  end

  def stub_find_protocol(obj)
    allow(Protocol).to receive(:find).
        with(obj.id).
        and_return(obj)
    allow(Protocol).to receive(:find).
        with(obj.id.to_s).
        and_return(obj)
  end

  def stub_find_project_role(obj)
    allow(ProjectRole).to receive(:find).
        with(obj.id.to_s).
        and_return(obj)
  end
end