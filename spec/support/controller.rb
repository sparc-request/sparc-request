# coding: utf-8
# Copyright © 2011-2016 MUSC Foundation for Research Development
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
# them. opts allows you to specify the logged in user. Default behavior is
# to query the identities table for the record with id session[:identity_id].
# Sometimes it's desirable to use a mock Identity object; do stub_controller(obj: <mock identity>)
# in this case. If you don't want to use the session variable, do stub_controller(id: <identity id>).
def stub_controller(opts = {})
  before(:each) do
    allow(controller).to receive(:current_user) do
      if opts[:id]
        Identity.find_by_id(opts[:id])
      elsif opts[:obj]
        opts[:obj]
      else
        Identity.find_by_id(session[:identity_id])
      end
    end

    allow(controller).to receive(:authorize_identity) { }

    allow(controller).to receive(:authenticate_identity!) { }
  end
end

# Same as stub_controller, but for controllers which inherit from
# Portal::BaseController
def stub_portal_controller
  before(:each) do
    allow(controller).to receive(:authenticate_identity!) do
    end

    allow(controller).to receive(:current_identity) do
      Identity.find_by_id(session[:identity_id])
    end
  end
end

alias :stub_catalog_manager_controller :stub_portal_controller
