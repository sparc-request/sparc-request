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

RSpec.describe 'dashboard/sub_service_requests/show', type: :view do
  before(:each) do
    @protocol = build_stubbed(:protocol_without_validations)

    @service_request = build_stubbed(:service_request_without_validations, protocol: @protocol)
    assign(:service_request, @service_request)

    @sub_service_request = build_stubbed(:sub_service_request, service_request: @service_request)

    organization = Organization.new(name: "MegaCorp")
    allow(@sub_service_request).to receive(:organization).and_return(organization)
    allow(@sub_service_request).to receive(:protocol).and_return(@protocol)
    assign(:sub_service_request, @sub_service_request)

    @logged_in_user = build_stubbed(:identity)
    allow(@logged_in_user).to receive(:unread_notification_count).
      with(@sub_service_request.id).
      and_return("12345")
    ActionView::Base.send(:define_method, :current_user) { @logged_in_user }

    assign(:user, @logged_in_user)
    assign(:admin, "ADMIN")

    render
  end

  it "should display user's unread notifications count" do
    expect(response).to have_css("#notification_count", text: "12345")
  end

  it "should render header" do
    expect(response).to render_template(partial: "dashboard/sub_service_requests/_header", locals: { sub_service_request: @sub_service_request })
  end
end
