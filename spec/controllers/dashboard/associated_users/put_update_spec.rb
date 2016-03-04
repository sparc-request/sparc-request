require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'PUT update' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    describe 'authorization' do
      render_views

      context 'user not authorized to edit Protocol associated with ProjectRole' do
        it 'should render an error' do
          protocol = instance_double('Protocol',
            id: 1,
            type: :protocol_type)
          stub_find_protocol(protocol)
          authorize(identity_stub, protocol, can_edit: false)

          pr = instance_double('ProjectRole',
            id: 1,
            protocol: protocol)
          stub_find_project_role(pr)
          
          xhr :put, :update, id: pr.id

          expect(response).to render_template('service_requests/_authorization_error')
        end
      end
    end

    it 'should set @protocol_role from params[:id]' do

    end

    it 'should set @identity to Identity associated with @project_role' do

    end

    it 'should update @protocol_role using params[:project_role]' do

    end

    context 'updated @project_role not fully valid' do
      it 'should set @errors to @project_role\'s errors' do

      end
    end

    context 'params[:project_role][:role] == "primary-pi"' do
      it 'should change current Primary PI to a general access user with request rights' do

      end
    end

    it 'should set flash[:success]' do

    end

    context 'SEND_AUTHORIZED_USER_EMAILS == true' do
      it 'should notify certain authorized users' do

      end
    end

    context 'update revokes epic access from ProjectRole' do
      it 'should notify for epic user removal' do

      end
    end

    context 'update bestows epic access to ProjectRole' do
      it 'should notify for epic user approval' do

      end
    end

    context 'update changes epic rights of ProjectRole' do
      it 'should notify for epic rights change' do
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

    def stub_find_project_role(pr)
      allow(ProjectRole).to receive(:find).with(pr.id.to_s).and_return(pr)
    end

    def stub_find_protocol(protocol_stub)
      allow(Protocol).to receive(:find).with(protocol_stub.id.to_s).and_return(protocol_stub)
    end
  end
end
