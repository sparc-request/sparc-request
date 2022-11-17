# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

module APIHelper
  def send_api_update_request(args={})
    resource  = args[:resource]
    id        = args[:id]
    params    = args[:params] || {}
    token     = args[:token] || create(:api_access_token, application: create(:api_application)).token

    put "/api/v1/#{resource}/#{id}.json", params: params.merge(access_token: token)
  end

  def send_api_get_request(args={})
    resource  = args[:resource]
    id        = args[:id]
    ids       = args[:ids]
    depth     = args[:depth]
    params    = args[:params] || {}
    token     = args[:token] || create(:api_access_token, application: create(:api_application)).token

    params.merge!(ids: ids) if ids
    params.merge!(depth: depth) if depth

    if id
      get "/api/v1/#{resource}/#{id}.json", params: params.merge(access_token: token)
    else
      get "/api/v1/#{resource}.json", params: params.merge(access_token: token)
    end
  end
end

RSpec.configure do |config|
  config.include APIHelper, type: :request
end
