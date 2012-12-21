require 'spec_helper'

describe Portal::HomeController do
  # include EntityHelpers
  #
  # before(:each) do
  #   @protocol = make_project :short_title => "Obvious Waste of Taxpayer Dollars"
  #   @service = make_service :name => "Nutritional Snack"
  #   @service_request = ServiceRequest.new make_service_request(
  #     :subject_count => 12,
  #     :visit_count => 11,
  #     :line_items => [{:sub_service_request_id => "ssr_0",
  #                      :optional => true,
  #                      :service_id => @service['id'],
  #                      :is_one_time_fee => false}],
  #     :project_id => @protocol['id'])
  #   @related_service_requests = @service_request.related_service_requests
  # end
  #
  # describe "GET /" do
  #
  #   it "should know which service request's related information is being viewed (receiving from activiti)"
  #
  #   it "should know about the protocol which is being viewed" do
  #     ServiceRequest.should_receive(:find).and_return(@service_request)
  #     get 'index'
  #     assigns[:protocol].short_title.should eq("Obvious Waste of Taxpayer Dollars")
  #   end
  #
  #   it "should know who the current user is (recieving from activiti)"
  #
  #   it "should know about the related service requests" do
  #     ServiceRequest.should_receive(:find).and_return(@service_request)
  #     get 'index'
  #     assigns[:related_service_requests].count.should eq(1)
  #     assigns[:related_service_requests].first.service_request_id.should eq(@service_request.id)
  #   end
  #
  # end
  #
end
