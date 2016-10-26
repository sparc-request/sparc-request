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

class ProtocolFilter < ActiveRecord::Base

  belongs_to :identity

  serialize :with_organization, Array
  serialize :with_status, Array
  serialize :with_owner, Array

  attr_accessible :identity_id

  attr_accessible :search_name
  attr_accessible :show_archived
  attr_accessible :admin_filter
  attr_accessible :search_query
  attr_accessible :with_organization
  attr_accessible :with_status
  attr_accessible :with_owner

  scope :latest_for_user, -> (identity_id, limit) {
    where(identity_id: identity_id).
    order(created_at: :desc).
    limit(limit)
  }

  def href
    Rails.application.routes.url_helpers.
    dashboard_root_path(
      filterrific: {
        show_archived: (self.show_archived ? 1 : 0),
        admin_filter: self.admin_filter,
        search_query: self.search_query,
        with_organization: self.with_organization,
        with_status: self.with_status,
        with_owner: self.with_owner,
      }
    )
  end
end
