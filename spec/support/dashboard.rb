# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

# Same as stub_controller, but for controllers which inherit from
# Dashboard::BaseController
def log_in_dashboard_identity(opts = {})
  allow(controller).to receive(:authenticate_identity!) do
  end

  allow(controller).to receive(:current_identity) do
    if opts[:id]
      Identity.find_by_id(opts[:id])
    elsif opts[:obj]
      opts[:obj]
    else
      Identity.find_by_id(session[:identity_id])
    end
  end
end
alias :log_in_catalog_manager_identity :log_in_dashboard_identity


# Allows a stubbed object to be found.
# For example:
# line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
# expect(LineItem.find(line_item.id)).to eq(line_item)
#
# @param [Class] klass Eg. LineItem, SubServiceRequest, etc.
# @param block Block that produces the stubbed object. Must respond to #id.
def findable_stub(klass, &block)
  obj = block.call
  allow(klass).to receive(:find).
    with(obj.id).
    and_return(obj)
  allow(klass).to receive(:find).
    with(obj.id.to_s).
    and_return(obj)
  obj
end

# Allow (or forbid) access to a Protocol by an identity.
#
# @param identity
# @param protocol
# @param opts Authorization options
# @option opts :can_view (false) Grant view rights to identity
# @option opts :can_edit (false) Grant edit rights to identity
def authorize(identity, protocol, opts = {})
  auth_mock = instance_double(ProtocolAuthorizer,
    can_view?: opts[:can_view].nil? ? false : opts[:can_view],
    can_edit?: opts[:can_edit].nil? ? false : opts[:can_edit])
  allow(ProtocolAuthorizer).to receive(:new).
    with(protocol, identity).
    and_return(auth_mock)
end
