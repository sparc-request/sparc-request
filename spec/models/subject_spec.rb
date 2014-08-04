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

require 'spec_helper'

describe 'Subject' do
  context "methods" do
    let_there_be_lane
    let_there_be_j
    build_service_request_with_study

    let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, ssr_id: "0002", service_request_id: service_request.id, organization_id: program.id, status: "submitted") }
    let!(:service3)             { FactoryGirl.create(:service, organization_id: program.id, name: 'Per Patient') }
    let!(:line_item3)           { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service3.id, sub_service_request_id: sub_service_request2.id, quantity: 0) }

    before :each do
      add_visits
      build_clinical_data
    end

    describe "populate" do
    	it "should populate calendar with appointments, and procedures" do
    		arm1.subjects.size.should eq(2)
        arm1.subjects.first.calendar.appointments.size.should eq(arm1.visit_groups.size)

        line_item3.line_items_visits.first.procedures.size.should eq(20)

        li_id = line_item2.id
        line_item2.destroy
        Procedure.find_by_line_item_id(li_id).should eq(nil)
    	end
    end
  end
end