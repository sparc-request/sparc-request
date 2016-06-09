require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/project_roles.json' do

    before do
      protocol = build(:protocol)
      protocol.save validate: false

      user = create(:identity, ldap_uid: 'smarmy@musc.edu')
      create(:project_role, identity_id: user.id, protocol_id: protocol.id, project_rights: 'approve')

      @project_role_ids = ProjectRole.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('project_roles', 'shallow', @project_role_ids.pop(1)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Identities root object' do
          expect(response.body).to include('"project_roles":')
        end

        it 'should respond with an array of Identities' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['project_roles'].length).to eq(1)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('project_roles', 'shallow', @project_role_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['project_roles'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('project_roles', 'full', @project_role_ids) }

      it 'should respond with an array of project_roles and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ["identity_id", "protocol_id", "project_rights", "role", "role_other"].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['project_roles'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('project_roles', 'full_with_shallow_reflections', @project_role_ids) }

      it 'should respond with an array of project_roles and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ["identity_id", "protocol_id", "identity", "project_rights", "protocol", "role", "role_other"].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['project_roles'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
