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

# Stub out all the methods in ApplicationController so we're not testing
# them
def stub_controller
  before(:each) do
    controller.stub!(:current_user) do
      Identity.find_by_id(session[:identity_id])
    end

    controller.stub!(:load_defaults) do
      controller.instance_eval do
        @user_portal_link = '/portal'
        @default_mail_to  = 'nobody@nowhere.com'
      end
    end

    controller.stub!(:initialize_service_request) do
      controller.instance_eval do
        @service_request = ServiceRequest.find_by_id(session[:service_request_id])
        @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
        @line_items = @service_request.try(:line_items)
      end
    end

    controller.stub!(:authorize_identity) { }

    controller.stub!(:authenticate_identity!) { }

    controller.stub!(:setup_navigation) { }
  end
end

# Same as stub_controller, but for controllers which inherit from
# Portal::BaseController
def stub_portal_controller
  before(:each) do
    controller.stub!(:authenticate_identity!) do
    end

    controller.stub!(:current_identity) do
      Identity.find_by_id(session[:identity_id])
    end
  end
end

