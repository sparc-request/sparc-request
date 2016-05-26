require 'rails_helper'

RSpec.describe 'dashboard/notifications/_notifications', type: :view do
  include RSpecHtmlMatchers

  describe "recipient dropdown" do
    before(:each) do
      protocol = build_stubbed(:protocol)
      an_authorized_user = build_stubbed(:identity, first_name: "Jane", last_name: "Doe")
      allow(protocol).to receive(:project_roles).
        and_return([build_stubbed(:project_role,
          identity: an_authorized_user,
          protocol: protocol)])

      service_requester = build_stubbed(:identity, first_name: "John", last_name: "Doe")
      service_request = build_stubbed(:service_request, service_requester: service_requester, protocol: protocol)

      clinical_provider = build_stubbed(:identity, first_name: "Dr.", last_name: "Feelgood")
      organization = build_stubbed(:organization)
      # TODO refactor this out of view
      allow(organization).to receive_message_chain(:service_providers, :includes).
        with(:identity).
        and_return([build_stubbed(:clinical_provider, identity: clinical_provider, organization: organization)])

      @sub_service_request = build_stubbed(:sub_service_request, service_request: service_request, organization: organization)

      @logged_in_user = build_stubbed(:identity)
    end

    it "should show clinical providers and authorized users, but not the service requester" do
      render "dashboard/notifications/notifications", sub_service_request: @sub_service_request, user: @logged_in_user

      expect(response).to have_tag("select") do
        with_option(/Primary-pi: Jane Doe/)
        with_option(/Dr\. Feelgood/)
        without_option(/John Doe/)
      end
    end
  end
end
