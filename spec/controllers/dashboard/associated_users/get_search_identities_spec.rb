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

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET search_identities' do
    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
    end

    context "search term yields at least one matching record" do
      before(:each) do
        matching_record1 = instance_double(Identity,
          display_name: "My Good Name",
          id: 1,
          email: "user1@email.com")
        matching_record2 = instance_double(Identity,
          display_name: "Person",
          id: 2,
          email: "user2@email.com")
        allow(Identity).to receive(:search).with("ABC").and_return([matching_record1, matching_record2])

        get :search_identities, term: "\n ABC \n", format: :json
      end

      it "should render those results as json" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to eq([
          { "label" => "My Good Name", "value" => 1, "email" => "user1@email.com" },
          { "label" => "Person", "value" => 2, "email" => "user2@email.com" }])
      end

      it { is_expected.to respond_with :ok }
    end

    context "search term yields no matching records" do
      before(:each) do
        allow(Identity).to receive(:search).with("ABC").and_return([])

        get :search_identities, term: "\n ABC \n", format: :json
      end

      it "should render 'No Results' in json response" do
        expect(JSON.parse(response.body)).to eq([{ "label" => "No Results" }])
      end

      it { is_expected.to respond_with :ok }
    end
  end
end
