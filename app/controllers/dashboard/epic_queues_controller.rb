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

class Dashboard::EpicQueuesController < Dashboard::BaseController
  
  before_filter :get_epic_queue, only: [:destroy]
  before_filter :authorize_overlord

  def index
    respond_to do |format|
      format.json do
        @epic_queues = EpicQueue.all

        render
      end
      format.html do
        render
      end
    end
  end

  def destroy
    respond_to do |format|
      format.js do
        @epic_queue.destroy

        render
      end
    end
  end

  private

  # Check to see if user has rights to view epic queues
  def authorize_overlord
    unless QUEUE_EPIC_EDIT_LDAP_UIDS.include?(@user.ldap_uid)
      @epic_queues = nil
      @epic_queue = nil
      render partial: 'service_requests/authorization_error', locals: { error: 'You do not have access to view the Epic Queues', in_dashboard: false }
    end
  end

  def get_epic_queue
    @epic_queue = EpicQueue.find(params[:id])
  end
end
