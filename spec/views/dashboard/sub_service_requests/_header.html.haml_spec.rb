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

RSpec.describe 'dashboard/sub_service_requests/_header', type: :view do
  include RSpecHtmlMatchers

  before(:each) { stub_const("CLINICAL_WORK_FULFILLMENT_URL", "www.future-url.org") }

  describe "status dropdown" do
    it "should be populated with statuses from associated Organization" do
      protocol = stub_protocol
      organization = stub_organization
      sub_service_request = stub_sub_service_request(protocol: protocol, organization: organization)
      logged_in_user = build_stubbed(:identity)
      allow(logged_in_user).to receive(:unread_notification_count).
        with(sub_service_request.id).and_return("12345")
      stub_current_user(logged_in_user)
      allow(sub_service_request).to receive(:notes).and_return(["1"])
      allow(sub_service_request).to receive(:is_complete?).and_return(false)

      render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

      expect(response).to have_tag("select#sub_service_request_status") do
        with_option("Draft")
        with_option("NotDraft")
      end
    end
  end

  describe "owner dropdown" do
    context "SubServiceRequest in draft status" do
      it "should not be displayed" do
        protocol = stub_protocol
        organization = stub_organization
        sub_service_request = stub_sub_service_request(protocol: protocol,
          organization: organization,
          status: "draft")
        logged_in_user = build_stubbed(:identity)
        allow(logged_in_user).to receive(:unread_notification_count).
          with(sub_service_request.id).and_return("12345")
        stub_current_user(logged_in_user)
        allow(sub_service_request).to receive(:notes).and_return(["1"])
        allow(sub_service_request).to receive(:is_complete?).and_return(false)

        render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

        expect(response).not_to have_tag("select#sub_service_request_owner")
      end
    end

    context "SubServiceRequest not in draft status" do
      it "should be populated with candidate owners for SubServiceRequest" do
        protocol = stub_protocol
        organization = stub_organization
        sub_service_request_owner = build_stubbed(:identity, first_name: "Thing", last_name: "1")
        potential_owner = build_stubbed(:identity, first_name: "Thing", last_name: "2")
        sub_service_request = stub_sub_service_request(protocol: protocol,
          organization: organization,
          status: "not_draft",
          candidate_owners: [sub_service_request_owner, potential_owner])
        allow(sub_service_request).to receive(:owner_id).
          and_return(sub_service_request_owner.id)
        logged_in_user = build_stubbed(:identity)
        allow(logged_in_user).to receive(:unread_notification_count).
          with(sub_service_request).and_return("12345")
        stub_current_user(logged_in_user)
        allow(sub_service_request).to receive(:notes).and_return(["1"])
        allow(sub_service_request).to receive(:is_complete?).and_return(false)

        render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

        expect(response).to have_tag("select#sub_service_request_owner") do
          with_option("Thing 1")
          with_option("Thing 2")
        end
      end
    end
  end

  describe "fulfillment button" do
    context "SubServiceRequest ready for fulfillment" do
      context "and in fulfillment" do
        context "user has clinical provider rights" do
          it "should display the 'Go to Fulfillment' button, linking to CWF" do
            protocol = stub_protocol
            organization = stub_organization
            sub_service_request = stub_sub_service_request(protocol: protocol,
              organization: organization,
              status: "draft")
            allow(sub_service_request).to receive_messages(ready_for_fulfillment?: true,
              in_work_fulfillment?: true)
            logged_in_user = build_stubbed(:identity)
            allow(logged_in_user).to receive_messages(unread_notification_count: 12345,
              clinical_provider_rights?: true)
            stub_current_user(logged_in_user)
            allow(sub_service_request).to receive(:notes).and_return(["1"])
            allow(sub_service_request).to receive(:is_complete?).and_return(false)

            render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

            expect(response).to have_tag("a", text: "Go to Fulfillment",
              with: { href: CLINICAL_WORK_FULFILLMENT_URL })
          end
        end

        context "user does not have clinical provider rights" do
          it "should display the 'In Fulfillment' button, linking to CWF" do
            protocol = stub_protocol
            organization = stub_organization
            sub_service_request = stub_sub_service_request(protocol: protocol,
              organization: organization,
              status: "draft")
            allow(sub_service_request).to receive_messages(ready_for_fulfillment?: true,
              in_work_fulfillment?: true)
            logged_in_user = build_stubbed(:identity)
            allow(logged_in_user).to receive_messages(unread_notification_count: 12345,
              clinical_provider_rights?: false)
            stub_current_user(logged_in_user)
            allow(sub_service_request).to receive(:notes).and_return(["1"])
            allow(sub_service_request).to receive(:is_complete?).and_return(false)

            render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

            expect(response).to have_tag("a", text: "In Fulfillment", with: { href: CLINICAL_WORK_FULFILLMENT_URL })
          end
        end
      end

      context "and not in fulfillment" do
        it "should display the 'Send to FulFillment' button" do
          protocol = stub_protocol
          organization = stub_organization
          sub_service_request = stub_sub_service_request(protocol: protocol,
            organization: organization,
            status: "draft")
          allow(sub_service_request).to receive_messages(ready_for_fulfillment?: true,
            in_work_fulfillment?: false)
          logged_in_user = build_stubbed(:identity)
          allow(logged_in_user).to receive_messages(unread_notification_count: 12345)
          stub_current_user(logged_in_user)
          allow(sub_service_request).to receive(:notes).and_return(["1"])
          allow(sub_service_request).to receive(:is_complete?).and_return(false)

          render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

          expect(response).to have_tag("button", text: "Send to Fulfillment")
        end
      end
    end

    context "SubServiceRequest not ready for fulfillment" do
      it "should display a message indicating that the SSR is not ready" do
        protocol = stub_protocol
        organization = stub_organization
        sub_service_request = stub_sub_service_request(protocol: protocol,
          organization: organization,
          status: "draft")
        allow(sub_service_request).to receive_messages(ready_for_fulfillment?: false)
        logged_in_user = build_stubbed(:identity)
        allow(logged_in_user).to receive_messages(unread_notification_count: 12345)
        stub_current_user(logged_in_user)
        allow(sub_service_request).to receive(:notes).and_return(["1"])
        allow(sub_service_request).to receive(:is_complete?).and_return(false)

        render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

        expect(response).to have_tag("span", text: "Not enabled in SPARCCatalog.")
      end
    end
  end

  it "should display the current cost" do
    protocol = stub_protocol
    organization = stub_organization
    sub_service_request = stub_sub_service_request(protocol: protocol, organization: organization)
    logged_in_user = build_stubbed(:identity)
    allow(logged_in_user).to receive(:unread_notification_count).
      with(sub_service_request).and_return("12345")
    stub_current_user(logged_in_user)
    allow(sub_service_request).to receive(:notes).and_return(["1"])
    allow(sub_service_request).to receive(:is_complete?).and_return(false)

    render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

    expect(response).to have_tag("td.effective_cost", text: /\$543\.21/)
  end

  it "should display the user display cost" do
    protocol = stub_protocol
    organization = stub_organization
    sub_service_request = stub_sub_service_request(protocol: protocol, organization: organization)
    logged_in_user = build_stubbed(:identity)
    allow(logged_in_user).to receive(:unread_notification_count).
      with(sub_service_request).and_return("12345")
    stub_current_user(logged_in_user)
    allow(sub_service_request).to receive(:notes).and_return(["1"])
    allow(sub_service_request).to receive(:is_complete?).and_return(false)

    render "dashboard/sub_service_requests/header", sub_service_request: sub_service_request

    expect(response).to have_tag("td.display_cost", text: /\$543\.20/)
  end

  def stub_protocol
    build_stubbed(:protocol, short_title: "MyAwesomeProtocol")
  end

  # specify protocol and organization
  def stub_sub_service_request(opts = {})
    d = instance_double(SubServiceRequest,
      id: 1,
      protocol: opts[:protocol],
      organization: opts[:organization],
      ssr_id: "0001",
      status: opts[:status] || "NotDraft",             # default "NotDraft"
      candidate_owners: opts[:candidate_owners] || [], # default []
      ready_for_fulfillment?: opts[:ready_for_fulfillment?].nil? || opts[:ready_for_fulfillment?], # default true
      in_work_fulfillment?: opts[:in_work_fulfillment?].nil? || opts[:in_work_fulfillment?])       # default true

    # TODO refactor pricing, cost calculations
    effective_cost = 54321
    displayed_cost = 54320
    expect(d).to receive(:set_effective_date_for_cost_calculations) do
      allow(d).to receive(:direct_cost_total).and_return(effective_cost)
    end
    allow(d).to receive(:direct_cost_total).and_return(displayed_cost)
    expect(d).to receive(:unset_effective_date_for_cost_calculations) do
      allow(d).to receive(:direct_cost_total).and_return(displayed_cost)
    end

    d
  end

  def stub_organization(opts = {})
    default_statuses = { "draft" => "Draft", "not_draft" => "NotDraft" }
    instance_double(Organization,
      name: "MegaCorp",
      get_available_statuses: opts[:get_available_statuses].nil? ? default_statuses : opts[:get_available_statuses])
  end

  def stub_current_user(user)
    ActionView::Base.send(:define_method, :current_user) { user }
  end
end
