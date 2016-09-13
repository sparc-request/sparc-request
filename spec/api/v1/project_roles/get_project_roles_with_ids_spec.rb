# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
