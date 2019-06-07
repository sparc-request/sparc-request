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

RSpec.describe 'dashboard/sub_service_requests/_request_details', type: :view do
  include RSpecHtmlMatchers

  context "Export to excel" do
    it "should display service_request_id and sub_service_request_id in href" do
      protocol = create(:protocol, :without_validations, selected_for_epic: true)
      service_request = create(:service_request, :without_validations, protocol: protocol)
      org = create(:organization)
      create(:service, organization: org, send_to_epic: true)
      sub_service_request = create(:sub_service_request, protocol: protocol, service_request: service_request, organization: org)

      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)
      expect(response).to have_tag('a', with: { href: service_request_path(srid: service_request.id, admin_offset: 1, report_type: 'request_report', sub_service_request_id: sub_service_request.id, format: :xlsx) }, text: "Export to Excel")
    end
  end

  context "use_epic truthy" do
    stub_config("use_epic", true)
    
    it "should display 'Send to Epic' button" do
      protocol = create(:protocol, :without_validations, selected_for_epic: true)
      service_request = create(:service_request, :without_validations, protocol: protocol)
      org = create(:organization)
      create(:service, organization: org, send_to_epic: true)
      sub_service_request = create(:sub_service_request, protocol: protocol, service_request: service_request, organization: org)

      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)

      expect(response).to have_tag("button", text: /Send to Epic/)
    end
  end

  context "use_epic falsey" do
    stub_config("use_epic", false)
    it "should not display 'Send to Epic' button" do
      protocol = create(:protocol, :without_validations, selected_for_epic: true)
      service_request = create(:service_request, :without_validations, protocol: protocol)
      org = create(:organization)
      create(:service, organization: org, send_to_epic: true)
      sub_service_request = create(:sub_service_request, protocol: protocol, service_request: service_request, organization: org)

      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)

      expect(response).not_to have_tag("button", text: /Send to Epic/)
    end
  end

  context "SubServiceRequest associated with CTRC Organization" do
    it "should display 'Administrative Approvals' button" do
      protocol = create(:protocol, :without_validations, selected_for_epic: true)
      service_request = create(:service_request, :without_validations, protocol: protocol)
      org = create(:organization, :ctrc)
      create(:service, organization: org, send_to_epic: true)
      sub_service_request = create(:sub_service_request, protocol: protocol, service_request: service_request, organization: org)

      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)

      expect(response).to have_tag("button", text: /Administrative Approvals/)
    end
  end

  context "SubServiceRequest eligible for Subsidy" do
    it "should render subsidies" do
      protocol = stub_protocol
      service_request = stub_service_request(protocol: protocol)
      sub_service_request = stub_sub_service_request(service_request: service_request, protocol: protocol, eligible_for_subsidy?: true)

      allow(sub_service_request).to receive_messages(approved_subsidy: nil, pending_subsidy: nil)
      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)

      expect(response).to render_template(partial: "dashboard/subsidies/_subsidy", locals: { sub_service_request: sub_service_request, admin: true })
    end
  end

  context "SubServiceRequest not eligible for Subsidy" do
    it "should not render subsidies" do
      protocol = stub_protocol
      service_request = stub_service_request(protocol: protocol)
      stub_sub_service_request(service_request: service_request, eligible_for_subsidy?: false)

      expect(response).not_to render_template(partial: "dashboard/subsidies/_subsidy")
    end
  end

  def render_request_details(opts = {})
    render "dashboard/sub_service_requests/request_details", opts
  end

  def stub_protocol
    build_stubbed(:protocol)
  end

  def stub_service_request(opts = {})
    build_stubbed(:service_request,
      protocol: opts[:protocol])
  end

  # specify protocol and organization
  def stub_sub_service_request(opts = {})
    obj = build_stubbed(:sub_service_request,
      service_request: opts[:service_request], protocol: opts[:protocol])
    allow(obj).to receive(:ctrc?).
      and_return(!!opts[:ctrc?])
    allow(obj).to receive(:eligible_for_subsidy?).
      and_return(!!opts[:eligible_for_subsidy?])
    obj
  end

  def stub_organization(opts = {})
    build_stubbed(:organization)
  end

  def stub_current_user(user)
    ActionView::Base.send(:define_method, :current_user) { user }
  end
end
