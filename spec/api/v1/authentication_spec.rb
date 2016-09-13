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

  describe 'authentication' do

    before do
      @protocol = build(:protocol)
      @protocol.save validate: false
    end

    context 'success' do

      before { cwf_sends_api_get_request_for_resource('protocols', @protocol.id, 'shallow') }

      it 'should allow the request' do
        expect(response.code).to eq('200')
      end
    end

    context 'failure' do

      context 'bad username' do

        before do
          bad_username = 'bad_username'

          http_login(bad_username, REMOTE_SERVICE_NOTIFIER_PASSWORD)

          get "/v1/protocols/#{@protocol.id}.json", @env
        end

        it 'should not allow the request' do
          expect(response.code).to eq('401')
        end

        it 'should not respond' do
          expect(response.body).to be_empty
        end
      end

      context 'bad password' do

        before do
          bad_password = 'bad_password'

          http_login(REMOTE_SERVICE_NOTIFIER_USERNAME, bad_password)

          get "/v1/protocols/#{@protocol.id}.json", @env
        end

        it 'should not allow the request' do
          expect(response.code).to eq('401')
        end

        it 'should not respond' do
          expect(response.body).to be_empty
        end
      end
    end
  end
end
