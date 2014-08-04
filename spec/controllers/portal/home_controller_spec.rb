# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
