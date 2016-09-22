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

module CwfHelper

  def cwf_sends_api_put_request_for_resource(klass, object_id, params)
    http_login

    put "/v1/#{klass}/#{object_id}.json", params, @env
  end

  def cwf_sends_api_get_request_for_resource(klass, object_id, depth)
    http_login

    if depth
      params = { depth: depth }
    else
      params = {}
    end

    get "/v1/#{klass}/#{object_id}.json", params, @env
  end

  def cwf_sends_api_get_request_for_resources(klass, depth, ids=[])
    http_login

    params = Hash.new

    if ids.any?
      params.merge!({ ids: ids })
    end

    if depth.present?
      params.merge!({ depth: depth })
    end

    get "/v1/#{klass}.json", params, @env
  end

  def cwf_sends_api_get_request_for_resources_by_params(klass, params)
    http_login

    get "/v1/#{klass}.json", params, @env
  end
end

RSpec.configure do |config|
  config.include CwfHelper, type: :request
end
