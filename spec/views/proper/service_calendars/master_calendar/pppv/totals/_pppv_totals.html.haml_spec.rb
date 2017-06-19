# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe '/service_calendar/master_calendar/pppv/totals/_pppv_totals', type: :view do

  let_there_be_lane

  before(:each) do
    @protocol        = create(:unarchived_study_without_validations, id: 1, primary_pi: jug2)
    @service_request = create(:service_request_without_validations, protocol: @protocol)
    @arm            = create(:arm, protocol: @protocol, name: 'Arm')
    @visit_group1    = create(:visit_group, arm: @arm)
    @liv             = []
  end

  it 'should display maximum total direct cost per patient if USE_INDIRECT_COST is true' do
    stub_const("USE_INDIRECT_COST", true)
    render "/service_calendars/master_calendar/pppv/totals/pppv_totals", tab: 'calendar', arm: @arm, line_items_visits: @liv, page: '1'

    expect(response).to have_content('Maximum Total Direct Costs Per Patient')
  end

  it 'should not display maximum total direct cost per patient if USE_INDIRECT_COST is false' do
    stub_const("USE_INDIRECT_COST", false)
    render "/service_calendars/master_calendar/pppv/totals/pppv_totals", tab: 'calendar', arm: @arm, line_items_visits: @liv, page: '1'

    expect(response).to_not have_content('Maximum Total Direct Costs Per Patient')
  end

  it 'should display maximum total cost per patient' do
    render "/service_calendars/master_calendar/pppv/totals/pppv_totals", tab: 'calendar', arm: @arm, line_items_visits: @liv, page: '1'

    expect(response).to have_content('Maximum Total Per Patient')
  end

  it 'should not display total cost per arm' do
    render "/service_calendars/master_calendar/pppv/totals/pppv_totals", tab: 'calendar', arm: @arm, line_items_visits: @liv, page: '1'
    
    expect(response).to have_content("Total Costs (Clinical Services) Per Study -- #{@arm.name}")
  end
end