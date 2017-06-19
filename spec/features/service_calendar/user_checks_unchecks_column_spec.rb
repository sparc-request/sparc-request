# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe 'User checks and unchecks calendar columns', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    org       = create(:organization)
    org2      = create(:organization)
                create(:pricing_setup, organization: org)
                create(:pricing_setup, organization: org2)
    service   = create(:service, organization: org, one_time_fee: false)
    service2  = create(:service, organization: org2, one_time_fee: false)

    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    @sr       = create(:service_request_without_validations, protocol: protocol)
    @ssr      = create(:sub_service_request, service_request: @sr, organization: org)
    @ssr2     = create(:sub_service_request, service_request: @sr, organization: org2)
    li        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
    li2       = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service2)
    
    @arm      = create(:arm, protocol: protocol)
  end

  context 'for SSRs which aren\'t locked' do
    before :each do
      stub_const('EDITABLE_STATUSES', { })
    end

    context 'check:' do
      scenario 'and sees all visits checked' do
        visit service_calendar_service_request_path(@sr)
        wait_for_javascript_to_finish

        find('.service-calendar-column').click

        expect(page).to have_css('.visit-quantity[checked]', count: 2)
     end
    end

    context 'uncheck:' do
      scenario 'and sees all visits unchecked' do
        @arm.visits.update_all(research_billing_qty: 1)
        visit service_calendar_service_request_path(@sr)

        find('.service-calendar-column').click
        wait_for_javascript_to_finish

        expect(page).to have_css('.visit-quantity[checked]', count: 0)
     end
    end
  end

  context 'for locked SSRs' do
    before :each do
      stub_const('EDITABLE_STATUSES', { @ssr2.organization.id => ['first_draft'] })
    end

    context 'check:' do
      scenario 'and sees the not-locked visits checked and the locked visits not checked' do
        visit service_calendar_service_request_path(@sr)
        wait_for_javascript_to_finish

        find('.service-calendar-column').click
        wait_for_javascript_to_finish

        expect(page).to have_css('.visit-quantity[checked]', count: 1)
        expect(all('.visit-quantity').last).to_not be_checked
      end
    end

    context 'uncheck:' do
      before :each do
        Visit.update_all(research_billing_qty: 1)
      end

      scenario 'and sees the not-locked visits unchecked and the locked visits checked' do
        visit service_calendar_service_request_path(@sr)
        wait_for_javascript_to_finish

        find('.service-calendar-column').click
        wait_for_javascript_to_finish

        expect(page).to have_css('.visit-quantity:checked', count: 1)
        expect(all('.visit-quantity').last).to be_checked
      end
    end
  end
end
