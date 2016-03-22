require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'get new' do
    context 'params[:protocol_type] == "project"' do
      it 'should set @protocol_type to "project"' do
        identity = identity_stub(admin: false)
        log_in_dashboard_identity(obj: identity)

        get :new, protocol_type: 'project'

        expect(assigns(:protocol_type)).to eq('project')
      end

      it 'should set @protocol to a new Project with requester equal to logged in user' do
        identity = identity_stub(admin: false)
        log_in_dashboard_identity(obj: identity)

        get :new, protocol_type: 'project'

        expect(assigns(:protocol).class.name).to eq('Project')
        expect(assigns(:protocol).id).to eq(nil)
        expect(assigns(:protocol).requester_id).to eq(1)
      end

      it 'should set session[:protocol_type] to "project"' do
        identity = identity_stub(admin: false)
        log_in_dashboard_identity(obj: identity)

        get :new, protocol_type: 'project'

        expect(session[:protocol_type]).to eq('project')
      end
    end

    context 'params[:protocol_type] == "study"' do
      it 'should set @protocol_type to "study"' do
        identity = identity_stub(admin: false)
        log_in_dashboard_identity(obj: identity)

        get :new, protocol_type: 'study'

        expect(assigns(:protocol_type)).to eq('study')
      end

      it 'should set @protocol to a new Study with requester equal to logged in user' do
        identity = identity_stub(admin: false)
        log_in_dashboard_identity(obj: identity)

        get :new, protocol_type: 'study'

        expect(assigns(:protocol).class.name).to eq('Study')
        expect(assigns(:protocol).id).to eq(nil)
        expect(assigns(:protocol).requester_id).to eq(1)
      end

      it 'should set session[:protocol_type] to "study"' do
        identity = identity_stub(admin: false)
        log_in_dashboard_identity(obj: identity)

        get :new, protocol_type: 'study'

        expect(session[:protocol_type]).to eq('study')
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
end
