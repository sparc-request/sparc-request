# TODO fix and refactor
require 'rails_helper'

RSpec.describe Dashboard::SubServiceRequestsController do
  # before(:each) { session[:breadcrumbs] = Dashboard::Breadcrumber.new }
  #
  # describe "GET show.js" do
  #   context "with params[:pages]" do
  #     it "should set session[:service_calendar_pages] to params[:pages]" do
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #
  #       service_request = instance_double(ServiceRequest,
  #                                         service_list: :service_list,
  #                                         protocol: instance_double(Protocol),
  #                                         arms: Arm.none)
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol),
  #                                             service_request: service_request,
  #                                             line_items: LineItem.none)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       xhr :get, :show, id: 1, pages: "my pages"
  #
  #       expect(session[:service_calendar_pages]).to eq("my pages")
  #     end
  #   end
  #
  #   context "with params[:arm_id] and params[:page]" do
  #     it "should set session[:service_calendar_pages][:arm_id] to params[:page]" do
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #
  #       service_request = instance_double(ServiceRequest,
  #                                         service_list: :service_list,
  #                                         protocol: instance_double(Protocol),
  #                                         arms: Arm.none)
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol),
  #                                             service_request: service_request,
  #                                             line_items: LineItem.none)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       stub_find_arm(instance_double(Arm, id: 2))
  #
  #       xhr :get, :show, id: 1, arm_id: 2, page: 3
  #
  #       expect(session[:service_calendar_pages]["2"]).to eq("3")
  #     end
  #   end
  #
  #   it "should assign @service_request to SubServiceRequest's ServiceRequest" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:service_request)).to eq(service_request)
  #   end
  #
  #   it "should assign @service_list to ServiceRequest's service list" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:service_list)).to eq("my service list")
  #   end
  #
  #   it "should assign @line_items to SubServiceRequest's LineItems" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:line_items)).to eq("my LineItems")
  #   end
  #
  #   it "should assign @protocol to ServiceRequest's Protocol" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:protocol)).to eq(service_request.protocol)
  #   end
  #
  #   it "should assign @tab to 'calendar'" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:tab)).to eq("calendar")
  #   end
  #
  #   it "should assign @portal to true" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:portal)).to eq(true)
  #   end
  #
  #   it "should assign @thead_class to 'default_calendar'" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:thead_class)).to eq("default_calendar")
  #   end
  #
  #   it "should assign @review to true" do
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #
  #     service_request = instance_double(ServiceRequest,
  #                                       service_list: "my service list",
  #                                       protocol: instance_double(Protocol),
  #                                       arms: Arm.none)
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           service_request: service_request,
  #                                           line_items: "my LineItems")
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     xhr :get, :show, id: 1
  #
  #     expect(assigns(:review)).to eq(true)
  #   end
  #
  #   context "with params[:arm_id]" do
  #     it "should assign @selected_arm to Arm from params[:arm_id]" do
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #
  #       service_request = instance_double(ServiceRequest,
  #                                         service_list: "my service list",
  #                                         protocol: instance_double(Protocol),
  #                                         arms: Arm.none)
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             service_request: service_request,
  #                                             line_items: "my LineItems")
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       arm = instance_double(Arm, id: 2)
  #       stub_find_arm(arm)
  #
  #       xhr :get, :show, id: 1, arm_id: 2
  #
  #       expect(assigns(:selected_arm)).to eq(arm)
  #     end
  #   end
  #
  #   xit "should assign @pages to something" do
  #
  #   end
  # end
  #
  # describe "GET show.html" do
  #   it "should set @sub_service_request from params[:id]" do
  #     organization = instance_double(Organization)
  #
  #     user = instance_double(Identity)
  #     log_in_dashboard_identity(obj: user)
  #     expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(false)
  #
  #     sub_service_request = instance_double(SubServiceRequest,
  #                                           id: 1,
  #                                           protocol: instance_double(Protocol, id: 2),
  #                                           organization: organization)
  #     stub_find_sub_service_request(sub_service_request)
  #
  #     get :show, id: 1
  #
  #     expect(assigns(:sub_service_request)).to eq(sub_service_request)
  #   end
  #
  #   context "with params[:service_calendar_pages]" do
  #     it "should set session[:service_calendar_pages]" do
  #       organization = instance_double(Organization)
  #
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #       expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(false)
  #
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol, id: 2),
  #                                             organization: organization)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       get :show, id: 1, pages: "my pages"
  #
  #       expect(session[:service_calendar_pages]).to eq("my pages")
  #     end
  #   end
  #
  #   context "without params[:service_calendar_pages]" do
  #     it "should not set session[:service_calendar_pages]" do
  #       organization = instance_double(Organization)
  #
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #       expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(false)
  #
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol, id: 2),
  #                                             organization: organization)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       get :show, id: 1
  #
  #       expect(session[:service_calendar_pages]).to eq(nil)
  #     end
  #   end
  #
  #   xit "should set session[:breadcrumbs] to reflect Dashboard heirarchy" do
  #
  #   end
  #
  #   context "user can edit fulfillment" do
  #     it "should set @service_request to SubServiceRequest's ServiceRequest" do
  #       organization = instance_double(Organization)
  #
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #       expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(true)
  #
  #       service_request = instance_double(ServiceRequest)
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol, id: 2),
  #                                             organization: organization,
  #                                             service_request: service_request)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       get :show, id: 1
  #
  #       expect(assigns(:service_request)).to eq(service_request)
  #     end
  #
  #     it "should set @admin to true" do
  #       organization = instance_double(Organization)
  #
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #       expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(true)
  #
  #       service_request = instance_double(ServiceRequest)
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol, id: 2),
  #                                             organization: organization,
  #                                             service_request: service_request)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       get :show, id: 1
  #
  #       expect(assigns(:admin)).to eq(true)
  #     end
  #
  #     it "should set @protocol to SubServiceRequest's Protocol" do
  #       organization = instance_double(Organization)
  #
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #       expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(true)
  #
  #       service_request = instance_double(ServiceRequest)
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol, id: 2),
  #                                             organization: organization,
  #                                             service_request: service_request)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       get :show, id: 1
  #
  #       expect(assigns(:protocol)).to eq(sub_service_request.protocol)
  #     end
  #
  #     it "should not redirect" do
  #       organization = instance_double(Organization)
  #
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #       expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(true)
  #
  #       service_request = instance_double(ServiceRequest)
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol, id: 2),
  #                                             organization: organization,
  #                                             service_request: service_request)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       get :show, id: 1
  #
  #       expect(response).to have_http_status(:ok)
  #     end
  #   end
  #
  #   context "user cannot edit fulfillment" do
  #     it "should redirect to Dashboard landing page" do
  #       organization = instance_double(Organization)
  #
  #       user = instance_double(Identity)
  #       log_in_dashboard_identity(obj: user)
  #       expect(user).to receive(:can_edit_fulfillment?).with(organization).and_return(false)
  #
  #       sub_service_request = instance_double(SubServiceRequest,
  #                                             id: 1,
  #                                             protocol: instance_double(Protocol, id: 2),
  #                                             organization: organization)
  #       stub_find_sub_service_request(sub_service_request)
  #
  #       get :show, id: 1
  #
  #       expect(response).to redirect_to("/dashboard")
  #     end
  #   end
  # end
  #
  # def stub_find_sub_service_request(ssr_stub)
  #   allow(SubServiceRequest).to receive(:find).with(ssr_stub.id.to_s).and_return(ssr_stub)
  # end
  #
  # def stub_find_arm(arm_stub)
  #   allow(Arm).to receive(:find).with(arm_stub.id.to_s).and_return(arm_stub)
  # end
end
