require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/project_role/:id.json' do

    before do
      protocol = FactoryGirl.build(:protocol)
      protocol.save validate: false

      @project_role = FactoryGirl.create(:project_role_with_identity, protocol: protocol)
    end

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('project_roles', @project_role.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a ProjectRole root object' do
          expect(response.body).to include('"project_role":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('project_roles', @project_role.id, 'shallow') }

      it 'should respond with a single shallow project_role' do
        expect(response.body).to eq("{\"project_role\":{\"sparc_id\":1,\"callback_url\":\"https://sparc.musc.edu/v1/project_roles/1.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('project_roles', @project_role.id, 'full') }

      it 'should respond with a ProjectRole' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ["identity_id", "protocol_id", "project_rights", "role", "role_other"].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['project_role'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('project_roles', @project_role.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of project_roles and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ["identity_id", "protocol_id", "identity", "project_rights", "protocol", "role", "role_other"].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['project_role'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
