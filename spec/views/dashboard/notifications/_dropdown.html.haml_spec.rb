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

RSpec.describe 'dashboard/notifications/_dropdown', type: :view do

  describe "recipient dropdown" do
    before(:each) do
      protocol = build_stubbed(:protocol)
      an_authorized_user = build_stubbed(:identity, first_name: "Jane", last_name: "Doe")
      allow(protocol).to receive(:project_roles).
        and_return([build_stubbed(:project_role,
          identity: an_authorized_user,
          protocol: protocol)])

      service_request = build_stubbed(:service_request, protocol: protocol)

      clinical_provider = build_stubbed(:identity, first_name: "Dr.", last_name: "Feelgood")
      organization = build_stubbed(:organization)
      allow(organization).to receive_message_chain(:service_providers, :includes).
        with(:identity).
        and_return([build_stubbed(:clinical_provider, identity: clinical_provider, organization: organization)])

      @sub_service_request = build_stubbed(:sub_service_request, service_request: service_request, organization: organization)

      @logged_in_user = build_stubbed(:identity)
    end
    it "should show clinical providers and authorized users" do
      render "dashboard/notifications/notifications", sub_service_request: @sub_service_request, user: @logged_in_user

      expect(response.include?("Primary-pi: Jane Doe")).to eq(true);
      expect(response.include?("Dr. Feelgood")).to eq(true);
    end
  end
end
