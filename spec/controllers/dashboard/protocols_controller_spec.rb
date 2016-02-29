require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'get index' do
    it 'should set @user to the currently user' do
      identity = identity_stub
      log_in_dashboard_identity(obj: identity)

      xhr :get, :index

      expect(assigns(:user)).to eq(identity)
    end

    it 'should use Filterrific to get protocols' do
      identity = identity_stub
      log_in_dashboard_identity(obj: identity)
      paginated_protocols = double('protocols', page: [:protocols])
      filterrific = double('filterrific', find: paginated_protocols)
      expect(controller).to receive(:initialize_filterrific).and_return(filterrific)

      xhr :get, :index

      expect(assigns(:protocols)).to eq [:protocols]
    end

    it 'should assign @protocol_filters to the five most recent filters' do
      identity = identity_stub
      log_in_dashboard_identity(obj: identity)
      expect(ProtocolFilter).to receive(:latest_for_user).with(identity.id, 5).and_return(:filters)

      xhr :get, :index

      expect(assigns(:protocol_filters)).to eq :filters
    end

    context 'user has admin organizations' do
      it 'should assign @admin to true' do
        identity = identity_stub(admin: true)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :index

        expect(assigns(:admin)).to eq(true)
      end
    end

    context 'user has no admin organizations' do
      it 'should assign @admin to false' do
        identity = identity_stub(admin: false)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :index

        expect(assigns(:admin)).to eq(false)
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
end
