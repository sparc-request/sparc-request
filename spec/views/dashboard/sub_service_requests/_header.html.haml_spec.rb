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

RSpec.describe 'dashboard/sub_service_requests/_header', type: :view do
  include RSpecHtmlMatchers

  let!(:org)      { create(:organization, :process_ssrs) }
  let!(:protocol) { create(:study_federally_funded) }
  let!(:sr)       { create(:service_request, protocol: protocol) }

  before(:each) do
    ActionView::Base.send(:define_method, :current_user) { FactoryBot.create(:identity) }
  end

  describe "status dropdown" do
    context 'SubServiceRequest has not been previously submitted' do
      it 'should disable the dropdown' do
        sub_service_request = create(:sub_service_request, protocol: protocol, service_request: sr, organization: org)

        render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

        expect(response).to have_selector('#requestStatus.disabled')
      end
    end
  end

  describe "owner dropdown" do
    context "SubServiceRequest in draft status" do
      it "should not be displayed" do
        sub_service_request = create(:sub_service_request, protocol: protocol, service_request: sr, organization: org, status: 'draft')

        render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

        expect(response).to have_no_selector('#requestOwner')
        expect(response).to have_content(I18n.t('dashboard.sub_service_requests.header.owner.not_available', status: PermissibleValue.get_value('status', 'draft')))
      end
    end
  end

  describe 'epic column' do
    context 'epic turned on, protocol selected for epic, and candidate servicees for epic' do
      stub_config('use_epic', true)

      before :each do
        @sub_service_request = create(:sub_service_request, protocol: protocol, service_request: sr, organization: org)
        allow(protocol).to receive(:selected_for_epic?).and_return(true)
        allow(@sub_service_request).to receive_message_chain(:candidate_services, :any?).and_return(true)
      end

      it 'should display the epic column' do
        render "dashboard/sub_service_requests/header", sub_service_request: @sub_service_request

        expect(response).to have_content(I18n.t('dashboard.sub_service_requests.header.epic.header'))
        expect(response).to have_selector('#pushToEpic')
      end

      context 'service request has errors' do
        it 'should display a warning' do
          allow(sr).to receive(:service_details_valid?).and_return(false)

          render "dashboard/sub_service_requests/header", sub_service_request: @sub_service_request

          expect(response).to have_selector('th i.fa-exclamation-circle.text-warning')
        end
      end
    end

    context 'don\'t use epic' do
      it 'should not display the epic column' do
        sub_service_request = create(:sub_service_request, protocol: protocol, service_request: sr, organization: org)

        render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

        expect(response).to have_no_selector('th', text: I18n.t('dashboard.sub_service_requests.header.epic.header'))
        expect(response).to have_no_selector('#pushToEpic')
      end
    end
  end

  describe 'fulfillment column' do
    before :each do
      @sub_service_request = create(:sub_service_request, protocol: protocol, service_request: sr, organization: org)
      org.tag_list << 'clinical work fulfillment'
    end

    context 'fulfillment turned on' do
      stub_config('fulfillment_contingent_on_catalog_manager', true)

      it 'should display the fulfillment column' do
        render "dashboard/sub_service_requests/header", sub_service_request: @sub_service_request

        expect(response).to have_selector('th', text: I18n.t('dashboard.sub_service_requests.header.fulfillment.header'))
        expect(response).to have_selector('#pushToFulfillment')
      end

      context 'service request has errors' do
        it 'should display a warning' do
          allow(sr).to receive(:service_details_valid?).and_return(false)

          render "dashboard/sub_service_requests/header", sub_service_request: @sub_service_request

          expect(response).to have_selector('th i.fa-exclamation-circle.text-warning')
        end
      end
    end

    context 'fulfillment turned off' do
      stub_config('fulfillment_contingent_on_catalog_manager', false)

      it 'should not display the fulfillment column' do
        render "dashboard/sub_service_requests/header", sub_service_request: @sub_service_request

        expect(response).to have_no_selector('th', text: I18n.t('dashboard.sub_service_requests.header.fulfillment.header'))
        expect(response).to have_no_selector('#pushToFulfillment')
      end
    end
  end
end
