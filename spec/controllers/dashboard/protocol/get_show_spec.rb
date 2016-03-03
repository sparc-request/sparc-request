require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'get show' do
    describe 'authorization' do
      let!(:identity) { create(:identity) }
      let!(:protocol) { create(:protocol_without_validations, type: 'Project') }
      before(:each) do
        log_in_dashboard_identity(obj: identity.reload)

        # controller action needs this; not related to auth
        ProjectRole.create(
          protocol_id: protocol.id,
          identity_id: identity.id,
          role: 'mentor',
          project_rights: 'primary-pi')
        protocol.reload
      end

      context 'user not authorized to view Protocol' do
        render_views
        it 'should render error message' do
          authorize(identity, protocol.becomes(Project), can_view: false)

          get :show, id: protocol.id, format: :html

          expect(response).to render_template('service_requests/_authorization_error')
        end
      end
    end

    context 'user authorized to view protocol' do
      let!(:identity) { create(:identity) }
      let!(:protocol) { create(:protocol_without_validations, type: 'Project') }
      let!(:pr) do
        ProjectRole.create(
          protocol_id: protocol.id,
          identity_id: identity.id,
          role: 'mentor',
          project_rights: 'primary-pi')
      end

      before(:each) do
        log_in_dashboard_identity(obj: identity.reload)

        protocol.reload

        authorize(identity, protocol.becomes(Project),
          can_view: true,
          can_edit: :permission_to_edit)
      end

      it 'should set @protocol' do
        get :show, id: protocol.id

        expect(assigns(:protocol)).to eq(protocol.becomes(Project))
      end

      it 'should set @protocol_role to the ProjectRole of the logged in user pertinent to the Protocol' do
        get :show, id: protocol.id

        expect(assigns(:protocol_role)).to eq(pr)
      end

      context 'format html' do
        it 'should set @permission_to_edit, @protocol_type, and @service_requests' do
          sr = create(:service_request_without_validations, protocol_id: protocol.id)
          get :show, id: protocol.id, format: :html

          expect(assigns(:permission_to_edit)).to eq(:permission_to_edit)
          expect(assigns(:protocol_type)).to eq 'Project'
          expect(assigns(:service_requests).to_a).to eq [sr]
        end
      end
    end
  end

  def identity_stub(opts = {})
    admin_orgs = opts[:admin] ? authorized_admin_organizations_stub : []
    instance_double('Identity',
      id: 1,
      authorized_admin_organizations: admin_orgs
    )
  end

  def authorized_admin_organizations_stub
    [instance_double('Organization',
      id: 1,
      name: 'MegaCorp')]
  end

  def authorize(identity, protocol, opts = {})
    auth_mock = instance_double('ProtocolAuthorizer',
      'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
      'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
    expect(ProtocolAuthorizer).to receive(:new).
      with(protocol, identity).
      and_return(auth_mock)
  end
end
