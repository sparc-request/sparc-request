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

RSpec.describe 'dashboard/sub_service_requests/_details', type: :view do
  let!(:org)      { create(:organization, :ctrc) }
  let!(:protocol) { create(:protocol, :without_validations, selected_for_epic: true) }
  let!(:sr)       { create(:service_request, :without_validations, protocol: protocol) }
  let!(:ssr)      { create(:sub_service_request, protocol: protocol, service_request: sr, organization: org) }

  context "SubServiceRequest associated with CTRC Organization" do
    it "should display Adnministrative Approvals checkboxes" do
      render 'dashboard/sub_service_requests/details', sub_service_request: ssr

      expect(response).to have_selector('#sub_service_request_nursing_nutrition_approved')
      expect(response).to have_selector('#sub_service_request_lab_approved')
      expect(response).to have_selector('#sub_service_request_imaging_approved')
      expect(response).to have_selector('#sub_service_request_committee_approved')
    end
  end

  context "SubServiceRequest eligible for Subsidy" do
    before :each do
      allow(ssr).to receive(:eligible_for_subsidy?).and_return(true)
    end

    it "should render subsidies" do
      render 'dashboard/sub_service_requests/details', sub_service_request: ssr

      expect(response).to render_template(partial: "subsidies/_subsidy", locals: { sub_service_request: ssr, admin: true, collapse: false })
    end
  end

  context "SubServiceRequest not eligible for Subsidy" do
    it "should not render subsidies" do
      expect(response).to_not render_template(partial: "subsidies/_subsidy")
    end
  end
end
