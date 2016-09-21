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

class ProtocolAuthorizer

  def initialize(protocol, identity)
    @protocol, @identity = protocol, identity
  end

  def can_edit?
    # NOTE @can_edit memoized; use #nil? since @can_edit is a boolean.
    # !! maps truthy and falsey values to true and false
    if @can_edit.nil?
      @can_edit = !!(@protocol && @identity && roles_for_edit.any?)
    else
      @can_edit
    end
  end

  def can_view?
    # NOTE @can_view memoized; use #nil? since @can_view is a boolean.
    # !! maps truthy and falsey values to true and false
    if @can_view.nil?
      @can_view = !!(@protocol && @identity &&
        (self.can_edit? || roles_for_view.any?))
    else
      @can_view
    end
  end

  private

  # 'approve' or 'request' ProjectRoles associating @user and @protocol
  def roles_for_edit
    @protocol.project_roles.where(identity_id: @identity.id,
      project_rights: ['approve', 'request'])
  end

  # 'view' ProjectRoles associating @user and @protocol
  def roles_for_view
    @protocol.project_roles.where(identity_id: @identity.id,
      project_rights: 'view')
  end
end
