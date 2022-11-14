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

class Dashboard::EpicQueuesController < Dashboard::BaseController
  before_action :get_epic_queue, only: [:destroy]
  before_action :authorize_epic_queue_access, :check_for_epic_connection

  def index
    respond_to do |format|
      format.html
      format.json {
        @epic_queues =
          if params[:user_change]
            EpicQueue.where(
              attempted_push: false,
              user_change: true
            )
          else
            EpicQueue.where(attempted_push: false, user_change: false)
          end.eager_load(:identity, protocol: :principal_investigators).
              search(params[:search]).ordered(params[:sort], params[:order])
      }
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
  def authorize_epic_queue_access
    unless Setting.get_value("use_epic") && Setting.get_value("epic_queue_access").include?(current_user.ldap_uid)
      authorization_error('You do not have access to view the Epic Queues')
    end
  end

  def check_for_epic_connection
    @epic_user = EpicUser.for_identity(current_user)
    @epic_connection = nil

    if @epic_user.present?
      @epic_connection = true 
    else
      @epic_connection = false 
    end
  end

  def get_epic_queue
    @epic_queue = EpicQueue.find(params[:id])
  end
end
