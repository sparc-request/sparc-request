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

  describe 'GET #new' do

    before(:each) do
      @user = build(:identity, protocol_filter_count: 3)

      @filterrific = { sorted_by: "id desc",
                       search_query: {search_drop: '', search_text: ''} }

      log_in_dashboard_identity(obj: @user)
    end

    it "creates the appropriate project filter object" do
      get :new, params: { filterrific: @filterrific }, xhr: true
      expect( assigns(:protocol_filter).attributes ).to eq( build(:protocol_filter, identity_id: @user.id, search_query: '{"search_drop"=>"", "search_text"=>""}').attributes )
    end

    it "adds the filter to the user's protocol filter list" do
      expect{ get :new, params: { filterrific: @filterrific }, xhr: true }.to change{ @user.protocol_filters.length }.by(1)
    end

    it "doesn't save the project filter object" do
      expect{ get :new, params: { filterrific: @filterrific }, xhr: true }.to_not change{ ProtocolFilter.count }
    end

  end

end
