# Copyright © 2011-2022 MUSC Foundation for Research Development
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

class Dashboard::OncoreRecordsController < Dashboard::BaseController
  before_action :authorize_oncore_endpoint_access

  def index
    respond_to do |format|
      format.html
      format.json {
        @oncore_records = OncoreRecord.most_recent_push_per_protocol.eager_load(protocol: [:primary_pi, :principal_investigators])
      }
    end
  end

  # Shows all OnCore Records for a particular protocol
  def history
    respond_to do |format|
      format.js {
        @protocol_id = params[:protocol_id]
      }
      format.json {
        @oncore_records = OncoreRecord.where(protocol_id: params[:protocol_id])
      }
    end
  end

  private

  # Check to see if the user has access to view OnCore records
  def authorize_oncore_endpoint_access
    unless Setting.get_value("oncore_endpoint_access").include?(current_user.ldap_uid)
      authorization_error('You do not have OnCore Endpoint access.')
    end
  end
end
