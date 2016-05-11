require 'rails_helper'

RSpec.describe 'dashboard/sub_service_requests/_per_patient_per_visit', type: :view do
  include RSpecHtmlMatchers

  context "SubServiceRequest has no pppv LineItems" do
    it "should indicate that there are no requests" do
      service_request = build_stubbed(:service_request)
      allow(service_request).to receive(:arms).and_return(["some arm"])
      sub_service_request = build_stubbed("sub_service_request")

      render "dashboard/sub_service_requests/per_patient_per_visit", sub_service_request: sub_service_request, service_request: service_request

      expect(response).to have_content("There are no per-patient/per-visit requests.")
    end
  end

  context "ServiceRequest has no Arms" do
    it "should indicate that there are no requests" do
      service_request = build_stubbed(:service_request)
      sub_service_request = build_stubbed(:sub_service_request)
      allow(sub_service_request).to receive(:per_patient_per_visit_line_items).
        and_return(["some line item"])

      render "dashboard/sub_service_requests/per_patient_per_visit", sub_service_request: sub_service_request, service_request: service_request

      expect(response).to have_content("There are no per-patient/per-visit requests.")
    end
  end

  context "SubServiceRequest has pppv LineItems and ServiceRequest has Arms" do
    it "should render study management buttons" do
      protocol = build_stubbed(:protocol)
      service_request = build_stubbed(:service_request, protocol: protocol)
      allow(service_request).to receive(:arms).and_return([:arm])
      sub_service_request = build_stubbed(:sub_service_request)
      allow(sub_service_request).to receive(:per_patient_per_visit_line_items).and_return([:line_item])

      render "dashboard/sub_service_requests/per_patient_per_visit", sub_service_request: sub_service_request, service_request: service_request

      expect(response).to render_template(partial: "study_schedule/management_buttons", locals: { service_request: service_request, sub_service_request: sub_service_request })
    end
  end
end
