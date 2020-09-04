# Copyright © 2011-2020 MUSC Foundation for Research Development
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

class API::TokensController < Doorkeeper::TokensController
  def create
    # Force the use of client_credentials authentication
    params[:grant_type] = 'client_credentials'
    headers.merge!(authorize_response.headers)
    if @authorize_response.is_a?(Doorkeeper::OAuth::ErrorResponse)
      create_access_request(status: 'failed', error: @authorize_response.body[:error_description])
    else
      create_access_request(status: 'token_given')
    end
    render json: authorize_response.body,
           status: authorize_response.status
  rescue Doorkeeper::Errors::DoorkeeperError => e
    create_access_request(status: 'failed', error: get_error_response_from_exception(e).body[:error_description])
    handle_token_exception(e)
  end

  private

  def create_access_request(args={ status: 'token_given' })
    Doorkeeper::AccessRequest.create(
      application_id:   Doorkeeper.config.application_model.by_uid(params[:client_id]).try(:id),
      access_token_id:  @authorize_response.try(:token).try(:id),
      ip_address:       request.remote_ip,
      status:           args[:status],
      failure_reason:   args[:error] ? args[:error] : nil
    )
  end
end
