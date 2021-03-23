# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

require "rails_helper"

RSpec.describe OncoreProtocol do

  let(:auth_path) { "/forte-platform-web/api/oauth/token" }
  let(:protocols_path) { "/oncore-api/rest/protocols" }
  let(:contacts_path) { "/oncore-api/rest/contacts" }
  let(:protocol_institutions_path) { "/oncore-api/rest/protocolInstitutions" }
  let(:protocol_staff_path) { "/oncore-api/rest/protocolStaff" }
  stub_config 'oncore_default_department', 'Other' #force setting to not be all caps to make sure department is capitalized

  before :each do
    @pi = create(:identity)
    @study = create(:study_federally_funded, primary_pi: @pi)
    @oncore_protocol = OncoreProtocol.new(@study)
  end

  describe '#initialize' do
    it 'should upcase the department to match OnCore' do
      expect(@oncore_protocol.department).to eq("OTHER")
    end
  end

  describe '#create_oncore_protocol' do
    it 'should send a POST request to OnCore four times' do
      @oncore_protocol.create_oncore_protocol
      # 1st to authenticate
      expect(a_request(:post, Setting.get_value("oncore_api")+auth_path)).to have_been_made.once
      # 2nd to create the protocol in OnCore
      expect(a_request(:post, Setting.get_value("oncore_api")+protocols_path)).to have_been_made.once
      # 3rd to add the institution to the protocol in OnCore
      expect(a_request(:post, Setting.get_value("oncore_api")+protocol_institutions_path)).to have_been_made.once
      # 4th to add the primary PI to the protcol in OnCore
      expect(a_request(:post, Setting.get_value("oncore_api")+protocol_staff_path)).to have_been_made.once
    end

    it 'should sent a GET request to OnCore twice' do
      @oncore_protocol.create_oncore_protocol
      # 1st to get the OnCore protocol id after creation
      expect(a_request(:get, Setting.get_value("oncore_api")+protocols_path).
        with(query: { "protocolNo" => "STUDY#{@study.id}" })).to have_been_made.once
      # 2nd to get the staff id of the primary PI
      expect(a_request(:get, Setting.get_value("oncore_api")+contacts_path).
        with(query: { "email" => @pi.email, "firstName" => @pi.first_name, "lastName" => @pi.last_name })).to have_been_made.once
    end
  end

  describe '#authenticate' do
    it 'should send a POST request to OnCore once' do
      @oncore_protocol.authenticate
      expect(a_request(:post, Setting.get_value("oncore_api")+auth_path)).to have_been_made.once
    end

    it 'should set the auth token' do
      @oncore_protocol.authenticate
      expect(@oncore_protocol.auth).to eq("Bearer some_token_value")
    end
  end
end
