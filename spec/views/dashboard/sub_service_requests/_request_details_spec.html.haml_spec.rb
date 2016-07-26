require 'rails_helper'

RSpec.describe 'dashboard/sub_service_requests/_request_details', type: :view do
  include RSpecHtmlMatchers

  context "Export to excel" do
    it "should display service_request_id and sub_service_request_id in href" do
      protocol = stub_protocol
      service_request = stub_service_request(protocol: protocol)
      sub_service_request = stub_sub_service_request(service_request: service_request)
      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)
      expect(response).to have_tag('a', with: { href: "/service_requests/#{service_request.id}.xlsx?admin_offset=1&sub_service_request_id=#{sub_service_request.id}" }, text: "Export to Excel")
    end
  end

  context "USE_EPIC truthy" do
    it "should display 'Send to Epic' button" do
      stub_const("USE_EPIC", true)
      protocol = stub_protocol
      service_request = stub_service_request(protocol: protocol)
      sub_service_request = stub_sub_service_request(service_request: service_request)

      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)

      expect(response).to have_tag("button", text: /Send to Epic/)
    end
  end

  context "USE_EPIC falsey" do
    it "should not display 'Send to Epic' button" do
      stub_const("USE_EPIC", false)

      protocol = stub_protocol
      service_request = stub_service_request(protocol: protocol)
      sub_service_request = stub_sub_service_request(service_request: service_request)

      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)

      expect(response).not_to have_tag("button", text: /Send to Epic/)
    end
  end

  context "SubServiceRequest associated with CTRC Organization" do
    it "should display 'Administrative Approvals' button" do
      protocol = stub_protocol
      service_request = stub_service_request(protocol: protocol)
      sub_service_request = stub_sub_service_request(service_request: service_request, ctrc?: true)

      render_request_details(protocol: protocol, service_request: service_request, sub_service_request: sub_service_request)

      expect(response).to have_tag("button", text: /Administrative Approvals/)
    end
  end

  context "SubServiceRequest eligible for Subsidy" do
    it "should render subsidies" do
      protocol = stub_protocol
      service_request = stub_service_request(protocol: protocol)
      sub_service_request = stub_sub_service_request(service_request: service_request, eligible_for_subsidy?: true)

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
      service_request: opts[:service_request])
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
