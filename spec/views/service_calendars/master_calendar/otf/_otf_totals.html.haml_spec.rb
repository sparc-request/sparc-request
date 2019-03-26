# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe '/service_calendar/master_calendar/otf/totals/_otf_totals', type: :view do

  let_there_be_lane

  before(:each) do
    @protocol        = create(:unarchived_study_without_validations, id: 1, primary_pi: jug2)
    @service_request = create(:service_request_without_validations, protocol: @protocol)
  end

  context 'indirect cost turned on' do
    stub_config("use_indirect_cost", true)

    it 'should display total direct costs for Non-clinical services' do
      render "/service_calendars/master_calendar/otf/totals/otf_totals", service_request: @service_request

      expect(response).to have_content('Total Direct Costs (Non-clinical Services) Per Study')
    end
  end

  context 'indirect cost turned off' do
    it 'should not display total direct costs for Non-clinical services' do
      render "/service_calendars/master_calendar/otf/totals/otf_totals", service_request: @service_request

      expect(response).to_not have_content('Total Direct Costs (Non-clinical Services) Per Study')
    end
  end

  it 'should display total Non-clinicals costs' do
    render "/service_calendars/master_calendar/otf/totals/otf_totals", service_request: @service_request

    expect(response).to have_content('Total Costs (Non-clinical Services) Per Study')
  end
end
