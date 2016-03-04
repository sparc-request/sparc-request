require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'put create' do
    context 'params[:protocol][:selected_for_epic] == true, USE_EPIC == true, QUEUE_EPIC == false' do
      it 'should notify for epic user approval' do
        identity = create(:identity)
        log_in_dashboard_identity(obj: identity)

        protocol_attributes = {
          short_title: 'a',
          title: 'b',
          funding_status: 'funded',
          funding_source: 'federal',
          type: 'Project',
          selected_for_epic: false,
          requester_id: identity.id,
          selected_for_epic: true,
          project_roles_attributes: [
            identity_id: identity.id,
            role: 'primary-pi',
            project_rights: 'approve'
          ]
        }

        stub_const('USE_EPIC', true)
        stub_const('QUEUE_EPIC', false)

        mail = double('mail')
        expect(mail).to receive(:deliver)
        expect(Notifier).to receive(:notify_for_epic_user_approval) do |protocol|
          mail
        end

        xhr :put, :create, format: :js, protocol: protocol_attributes
      end
    end

    context 'params[:protocol] does not describe a valid Protocol' do
      it 'should set @protocol to an unperisted Protocol and set @errors' do
        identity = create(:identity)
        log_in_dashboard_identity(obj: identity)

        protocol_attributes = { type: 'Project' }

        xhr :put, :create, format: :js, protocol: protocol_attributes

        expect(assigns(:protocol)).not_to be_persisted
        expect(assigns(:errors)).not_to be_nil
      end
    end

    context 'params[:protocol] describes a valid Protocol' do
      it 'should ensure that user is an authorized user of new Protocol' do
        identity = create(:identity)
        primary_pi = create(:identity)
        log_in_dashboard_identity(obj: identity)

        protocol_attributes = {
          short_title: 'a',
          title: 'b',
          funding_status: 'funded',
          funding_source: 'federal',
          type: 'Project',
          selected_for_epic: false,
          requester_id: identity.id,
          project_roles_attributes: [
            identity_id: primary_pi.id,
            role: 'primary-pi',
            project_rights: 'approve'
          ]
        }

        xhr :put, :create, format: :js, protocol: protocol_attributes

        expect(assigns(:protocol).project_roles.where(identity_id: identity.id)).not_to be_empty
      end

      it 'should assign @protocol to a newly created Protocol specified by params[:protocol]' do
        identity = create(:identity)
        log_in_dashboard_identity(obj: identity)

        protocol_attributes = {
          short_title: 'a',
          title: 'b',
          funding_status: 'funded',
          funding_source: 'federal',
          type: 'Project',
          selected_for_epic: false,
          requester_id: identity.id,
          project_roles_attributes: [
            identity_id: identity.id,
            role: 'primary-pi',
            project_rights: 'approve'
          ]
        }

        xhr :put, :create, format: :js, protocol: protocol_attributes

        # check that the new Protocol's attributes contains the ones
        # we requested
        _protocol_attributes = assigns(:protocol).attributes
        protocol_attributes.delete(:project_roles_attributes)
        protocol_attributes.delete(:requester_id) # this never seems to show up in attributes...
        expect(protocol_attributes.stringify_keys.to_a - _protocol_attributes.to_a).to be_empty
        expect(assigns(:protocol)).to be_persisted
        expect(assigns(:errors)).to be_nil
      end

      it 'should set flash[:success]' do
        identity = create(:identity)
        log_in_dashboard_identity(obj: identity)

        protocol_attributes = {
          short_title: 'a',
          title: 'b',
          funding_status: 'funded',
          funding_source: 'federal',
          type: 'Project',
          selected_for_epic: false,
          requester_id: identity.id,
          project_roles_attributes: [
            identity_id: identity.id,
            role: 'primary-pi',
            project_rights: 'approve'
          ]
        }

        xhr :put, :create, format: :js, protocol: protocol_attributes

        expect(flash[:success]).to eq('Project Created!')
      end
    end
  end
end
