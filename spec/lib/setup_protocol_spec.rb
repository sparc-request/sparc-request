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

RSpec.describe SetupProtocol, type: :model do 

  describe '#set_portal' do

    it 'should return true' do
      portal = 'true'
      identity = build_stubbed(:identity)
      protocol = build_stubbed(:protocol, identity: identity)
      service_request = build_stubbed(:service_request, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).set_portal

      expect(response).to eq 'true'
    end

    it 'should return false' do
      portal = 'false'
      identity = build_stubbed(:identity)
      protocol = build_stubbed(:protocol, identity: identity)
      service_request = build_stubbed(:service_request, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).set_portal

      expect(response).to eq 'false'
    end
  end

  describe '#find_service_request' do

    it 'should return the correct service request' do
      portal = 'false'
      identity = create(:identity)
      protocol = create(:protocol, :without_validations, identity: identity)
      service_request = create(:service_request, :without_validations, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).find_service_request

      expect(response).to eq service_request
    end
    
    it 'should return nil' do
      portal = 'true'
      identity = create(:identity)
      protocol = create(:protocol, :without_validations, identity: identity)
      service_request = create(:service_request, :without_validations, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).find_service_request

      expect(response).to eq nil
    end
  end

  describe '#requester_id' do

    it 'should return the correct requester id' do
      portal = 'true'
      identity = create(:identity)
      protocol = create(:protocol, :without_validations, identity: identity)
      service_request = create(:service_request, :without_validations, protocol: protocol)

      response = SetupProtocol.new(
        portal,
        protocol,
        identity,
        service_request.id
      ).requester_id

      expect(response).to eq identity.id
    end
  end
end

