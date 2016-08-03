
require 'rails_helper'

RSpec.describe 'dashboard/notifications/_dropdown', type: :view do

  describe "recipient dropdown" do
    before(:each) do
      protocol = build_stubbed(:protocol)
      an_authorized_user = build_stubbed(:identity, first_name: "Jane", last_name: "Doe")
      allow(protocol).to receive(:project_roles).
        and_return([build_stubbed(:project_role,
          identity: an_authorized_user,
          protocol: protocol)])

      service_request = build_stubbed(:service_request, protocol: protocol)

      clinical_provider = build_stubbed(:identity, first_name: "Dr.", last_name: "Feelgood")
      organization = build_stubbed(:organization)
      allow(organization).to receive_message_chain(:service_providers, :includes).
        with(:identity).
        and_return([build_stubbed(:clinical_provider, identity: clinical_provider, organization: organization)])

      @sub_service_request = build_stubbed(:sub_service_request, service_request: service_request, organization: organization)

      @logged_in_user = build_stubbed(:identity)
    end
    it "should show clinical providers and authorized users" do
      render "dashboard/notifications/notifications", sub_service_request: @sub_service_request, user: @logged_in_user

      expect(response.include?("Primary-pi: Jane Doe")).to eq(true);
      expect(response.include?("Dr. Feelgood")).to eq(true);
    end

  end
end