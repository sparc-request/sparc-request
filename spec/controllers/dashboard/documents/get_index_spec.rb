require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "GET #index" do

    let(:logged_in_user) { create(:identity) }
    let(:other_user) { create(:identity) }

    before :each do
      log_in_dashboard_identity(obj: logged_in_user)
    end

    context 'user is authorized to view protocol' do
      before :each do
        @protocol       = create(:protocol_without_validations, primary_pi: logged_in_user)
        @organization   = create(:organization)
        service_request = create(:service_request_without_validations, protocol: @protocol)
        @ssr            = create(:sub_service_request_without_validations, service_request: service_request, organization: @organization, status: 'draft')
                          create(:super_user, identity: logged_in_user, organization: @organization)

        get :index, protocol_id: @protocol.id, format: :json
      end

      it 'should assign @protocol' do
        expect(assigns(:protocol)).to eq(@protocol)
      end

      it 'should assign @admin' do
        expect(assigns(:admin)).to eq(true)
      end

      it 'should assign @authporization' do
        expect(assigns(:authorization)).to be
      end

      it 'should assign @documents' do
        expect(assigns(:documents)).to eq(@protocol.documents)
      end

      it 'should assign @permission_to_edit' do
        expect(assigns(:permission_to_edit)).to eq(true)
      end

      it 'should assign @admin_orgs' do
        expect(assigns(:admin_orgs)).to eq([@organization])
      end

      it { is_expected.to render_template "dashboard/documents/index" }
      it { is_expected.to respond_with :ok }
    end

    context 'user is authorized to view protocol' do
      before :each do
        protocol = create(:protocol_without_validations, primary_pi: other_user)

        get :index, protocol_id: protocol.id, format: :json
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/shared/_authorization_error" }
    end
  end
end
