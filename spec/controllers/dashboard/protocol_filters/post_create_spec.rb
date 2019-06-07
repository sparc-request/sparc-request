# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe Dashboard::ProtocolFiltersController do

  describe 'POST #create' do

    context 'successful' do

      before(:each) do
        @user = build(:identity, protocol_filter_count: 3)

        @protocol_filter = build(:protocol_filter, identity_id: @user.id)

        log_in_dashboard_identity(obj: @user)
      end

      it "creates a protocol filter record" do
        expect{ post :create, params: { protocol_filter: @protocol_filter.attributes }, xhr: true }.to change{ ProtocolFilter.count }.by(1)
      end

      it "adds the filter to the user's protocol filter list" do
        expect{ post :create, params: { protocol_filter: @protocol_filter.attributes }, xhr: true }.to change{ @user.protocol_filters.count }.by(1)
      end

      it "saves the correct attributes for the protocol filter" do
        post :create, params: { protocol_filter: @protocol_filter.attributes }, xhr: true
        expect( ProtocolFilter.last.attributes.except( 'id', 'created_at', 'updated_at' ) ).to eq(
          "identity_id" => @user.id, "search_name" => "", "show_archived" => nil, "search_query" => "", "with_organization" => [], "with_status" => [], "admin_filter" => "", "with_owner" => [])
      end

      it "flashes the correct message" do
        post :create, params: { protocol_filter: @protocol_filter.attributes }, xhr: true
        expect( flash[:success] ).to eq( 'Search Saved!' )
      end

    end

    #Leaving this section in in case we add validation to the protocol filter model
    #context 'unsuccessful' do

  end

end
