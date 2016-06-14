require 'rails_helper'

RSpec.describe 'dashboard/sub_service_requests/show', type: :view do
  before(:each) do
    @protocol = build_stubbed(:protocol_without_validations)

    @service_request = build_stubbed(:service_request_without_validations, protocol: @protocol, service_requester: build_stubbed(:identity))
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

  it "should render request details" do
    expect(response).to render_template(partial: "dashboard/sub_service_requests/_request_details", locals: { sub_service_request: @sub_service_request, service_request: @service_request, protocol: @protocol })
  end

  it "should render per patient per visit calendars" do
    expect(response).to render_template(partial: "dashboard/sub_service_requests/_per_patient_per_visit", locals: { sub_service_request: @sub_service_request, service_request: @service_request })
  end

  it "should render study level activities table" do
    expect(response).to render_template(partial: "dashboard/study_level_activities/study_level_activities_table", locals: { sub_service_request: @sub_service_request })
  end

  it "should render documents table" do
    expect(response).to render_template(partial: "dashboard/documents/documents_table", locals: { sub_service_request: @sub_service_request, service_request: @service_request })
  end

  it "should render status changes table" do
    expect(response).to render_template(partial: "dashboard/sub_service_requests/history/status_changes", locals: { sub_service_request_id: @sub_service_request.id })
  end

  it "should render notifications table" do
    expect(response).to render_template(partial: "dashboard/notifications/notifications", locals: { sub_service_request: @sub_service_request, user: @logged_in_user })
  end
end
