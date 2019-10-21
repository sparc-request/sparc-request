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

RSpec.describe 'dashboard/protocol_filters/_filter_protocols_form', type: :view do
  let_there_be_lane

  before(:each) do
    @filterrific = double('filterrific', :to_hash => {},
      select_options: {
        with_status: [],
        with_organization: [],
        sorted_by: "id_asc",
        with_owner: []
      },
      with_status: [],
      search_query: '',
      show_archived: 0,
      admin_filter: "for_identity #{jug2.id}",
      with_organization: false,
      sorted_by: "id_asc",
      with_owner: ["#{jug2.id}"]
    )
  end

  context 'user is not an admin' do
    before(:each) do
      render 'dashboard/protocol_filters/filter_protocols_form', filterrific: @filterrific, current_user: jug2, protocol_filters: [], reset_filterrific_url: '', admin: false
    end

    it 'should not show "My Protocols" radio' do
      expect(response).not_to have_content('My Protocols')
    end

    it 'should not show "My Admin Protocols" radio' do
      expect(response).not_to have_content('My Admin Protocols')
    end

    it 'should show "Organization" select' do
      expect(response).to have_content('Organization')
    end
  end

  context 'user is an admin' do
    before(:each) do
      render 'dashboard/protocol_filters/filter_protocols_form', filterrific: @filterrific, current_user: jug2, protocol_filters: [], reset_filterrific_url: '', admin: true
    end

    it 'should show "My Protocols" radio' do
      expect(response).to have_selector('label', text: 'My Protocols')
    end

    it 'should show "My Admin Protocols" radio' do
      expect(response).to have_selector('label', text: 'My Admin Protocols')
    end
  end
end
