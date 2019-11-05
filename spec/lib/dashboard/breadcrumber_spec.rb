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

RSpec.describe Dashboard::Breadcrumber do
  include RSpecHtmlMatchers

  before(:each) { @breadcrumber = Dashboard::Breadcrumber.new }

  describe '#clear' do
    context 'with no arguments' do
      it 'should remove every breadcrumb' do
        @breadcrumber.add_crumb(:protocol_id, 1)

        @breadcrumber.clear

        breadcrumbs = @breadcrumber.breadcrumbs
        expect(breadcrumbs).to have_tag('a', count: 1)
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
      end
    end

    context 'with symbol' do
      it 'should remove that breadcrumb' do
        @breadcrumber.add_crumb(:protocol_id, 1)

        @breadcrumber.clear(criumb: :protocol_id)

        breadcrumbs = @breadcrumber.breadcrumbs
        expect(breadcrumbs).to have_tag('a', count: 1)
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
      end
    end
  end

  describe '#add_crumb' do
    it 'should add a breadcrumb' do
      allow(Protocol).to receive(:find).with(1).and_return(instance_double(Protocol, short_title: "My Protocol"))

      @breadcrumber.add_crumb(:protocol_id, 1)

      breadcrumbs = @breadcrumber.breadcrumbs
      expect(breadcrumbs).to have_tag('li', text: "(1) My Protocol")
    end
  end

  describe '#add_crumbs' do
    let(:identity)  { create(:identity, email: 'nobody@nowhere.com') }
    let(:org)       { create(:organization, abbreviation: 'SPEW') }
    let(:protocol)  { create(:protocol_without_validations, type: "Study", short_title: "My Protocol") }
    let(:service_request) { create(:service_request_without_validations, protocol: protocol) }
    let(:ssr)       { create(:sub_service_request_without_validations, organization: org, protocol: protocol, service_request: service_request, owner: build(:identity)) }

    it 'should add multiple breadcrumbs' do
      @breadcrumber.add_crumbs(protocol_id: protocol.id, sub_service_request_id: ssr.id)

      breadcrumbs = @breadcrumber.breadcrumbs
      expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols/1" }, text: "(1) My Protocol" )
      expect(breadcrumbs).to have_tag('li', text: "(#{ssr.ssr_id}) SPEW")
    end
  end

  describe '#breadcrumbs' do

    let(:identity)  { create(:identity, email: 'nobody@nowhere.com') }
    let(:org)       { create(:organization, abbreviation: 'SPEW') }
    let(:protocol)  { create(:protocol_without_validations, type: "Study", short_title: "My Protocol") }
    let(:service_request) { create(:service_request_without_validations, protocol: protocol) }
    let(:ssr)       { create(:sub_service_request_without_validations, organization: org, protocol: protocol, service_request: service_request, owner: build(:identity)) }

    context 'with no crumbs' do
      it 'should return link to Dashboard' do
        breadcrumbs = @breadcrumber.breadcrumbs
        expect(breadcrumbs).to have_tag('a', count: 1)
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
      end
    end

    context 'with crumbs' do
      it 'should render the links with the correct text in the correct order' do
        @breadcrumber.add_crumbs(protocol_id: protocol.id, sub_service_request_id: ssr.id, edit_protocol: 1)

        breadcrumbs = @breadcrumber.breadcrumbs

        expect(breadcrumbs).to have_tag('a', count: 3) # expect correct number of links, so the following is exhaustive
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols/#{protocol.id}" }, text: "(#{protocol.id}) My Protocol")
        expect(breadcrumbs).to have_tag('li', text: "Edit")
        expect(breadcrumbs).to match(/Dashboard.*My Protocol.*Edit/) # expect correct order
      end
    end
  end
end
