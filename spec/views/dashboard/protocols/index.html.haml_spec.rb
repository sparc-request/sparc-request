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

RSpec.describe 'dashboard/protocols/index', type: :view do
  let_there_be_lane

  before(:each) do
    assign(:user, jug2)
    assign(:filterrific, double('filterrific',
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
    ))
    assign(:filterrific_params, { test: 'test' } )
  end

  describe 'Protocol filters' do
    context 'no ProtocolFilters present' do
      before(:each) do
        assign(:protocols, [].paginate(page: 1))
        render
      end

      it 'should not display list' do
        expect(response).not_to have_content('Recently Saved Filters')
      end
    end

    context 'ProtocolFilters present' do
      before(:each) do
        assign(:protocol_filters, [double('protocol_filter',
          search_name: 'My Awesome Filter',
          href: ''
        )])
        assign(:protocols, [].paginate(page: 1))
        render
      end

      it 'should display list' do
        expect(response).to have_content('Recently Saved Filters')
      end

      it 'should display their names' do
        expect(response).to have_content('My Awesome Filter')
      end
    end
  end

  describe 'filter pane' do
    context 'user is not an admin' do
      before(:each) do
        assign(:admin, false)
        assign(:protocols, [].paginate(page: 1))
        render
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
        assign(:admin, true)
        assign(:protocols, [].paginate(page: 1))

        render
      end

      it 'should show "My Protocols" radio' do
        expect(response).to have_selector('label', text: 'My Protocols')
      end

      it 'should show "My Admin Protocols" radio' do
        expect(response).to have_selector('label', text: 'My Admin Protocols')
      end
    end
  end

  describe 'Protocols list' do
    describe 'Protocol info' do
      before(:each) do
        create(:super_user, identity_id: jug2.id)
        protocol = build(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Project',
          archived: false,
          short_title: 'My Awesome Short Tite')
        allow(protocol).to receive(:principal_investigators).
          and_return [
            instance_double('Identity',
              full_name: 'Santa Claws'),
            instance_double('Identity',
              full_name: 'Toof Fairy')
          ]
        assign(:protocols, [protocol].paginate(page: 1))
        render
      end

      it 'should display id' do
        expect(response).to have_selector('td', exact: '9999')
      end

      it 'should display short title' do
        expect(response).to have_selector('td', exact: 'My Awesome Short Title')
      end

      it 'should display PIs' do
        expect(response).to have_selector('td', exact: 'Santa Claws, Toof Fairy')
      end
    end

    describe 'archive button' do
      context 'unarchived Project on page' do
        it "should display 'Archive Project'" do
          assign(:protocols, [build(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)].paginate(page: 1))

          render template: 'dashboard/protocols/index.html.haml'

          expect(response).to have_selector('button', exact: 'Archive Project')
        end
      end

      context 'unarchived Study on page' do
        it "should display 'Archive Study'" do
          assign(:protocols, [build(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)].paginate(page: 1))

          render template: 'dashboard/protocols/index.html.haml'

          expect(response).to have_selector('button', exact: 'Archive Study')
        end
      end

      context 'archived Project on page' do
        it "should display 'Unarchive Project'" do
          assign(:protocols, [build(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)].paginate(page: 1))

          render template: 'dashboard/protocols/index.html.haml'

          expect(response).to have_selector('button', exact: 'Unarchive Project')
        end
      end

      context 'archived Study on page' do
        it "should display 'Unarchive Study'" do
          assign(:protocols, [build(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: true)].paginate(page: 1))

          render template: 'dashboard/protocols/index.html.haml'

          expect(response).to have_selector('button', exact: 'Unarchive Study')
        end
      end
    end

    describe 'requests button' do
      context 'Protocol has no ServiceRequests' do
        it 'should not display button' do
          protocol = build(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
          allow(protocol).to receive(:service_requests).and_return []
          assign(:protocols, [protocol].paginate(page: 1))

          render

          expect(response).not_to have_selector('button', text: 'Requests')
        end
      end

      context 'Protocol has a SubServiceRequest' do
        it 'should display button' do
          protocol = build(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
          allow(protocol).to receive(:service_requests).and_return []
          assign(:protocols, [protocol].paginate(page: 1))

          render
          
          expect(response).to have_selector('button', exact: 'Requests')
        end
      end
    end
  end
end
