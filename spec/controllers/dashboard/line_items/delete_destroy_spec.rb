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

require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe 'DELETE #destroy' do

    context 'one time fee' do
      it 'should delete a line item' do
        line_item = create(:line_item, :one_time_fee, :without_validations)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        delete :destroy, params: { id: line_item.id }, xhr: true

        expect(response).to have_http_status(:ok)
      end
    end

    context 'not a one time fee' do
      it 'should delete line item' do
        sr = create(:service_request, :without_validations)
        ssr = create(:sub_service_request, :without_validations, :with_organization, service_request: sr)
        line_item = create(:line_item, :with_service, :without_validations, sub_service_request: ssr)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        delete :destroy, params: { id: line_item.id }, xhr: true

        expect(response).to have_http_status(:ok)
      end
    end
  end
end

