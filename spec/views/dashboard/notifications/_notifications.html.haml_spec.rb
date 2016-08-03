require 'rails_helper'

RSpec.describe 'dashboard/notifications/_notifications', type: :view do

  describe "recipient dropdown" do
    before(:each) do
      protocol             = build_stubbed(:protocol)
      service_request      = build_stubbed(:service_request, protocol: protocol)
      organization         = build_stubbed(:organization)
      @sub_service_request = build_stubbed(:sub_service_request, service_request: service_request, organization: organization)
      @logged_in_user      = build_stubbed(:identity)
    end

    it "should render dashboard/notifications/_dropdown.html.haml" do
      render "dashboard/notifications/notifications", sub_service_request: @sub_service_request, user: @logged_in_user

      expect(response).to render_template(partial: 'dashboard/notifications/dropdown',
              locals: { sub_service_request: @sub_service_request, user: @logged_in_user })
    end
  end
end
