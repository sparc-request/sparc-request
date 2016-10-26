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

class RemoteServiceNotifierJob < Struct.new(:object_id, :object_class, :action)

  class RemoteServiceNotifierError < StandardError
  end

  def self.enqueue(object_id, object_class, action)
    job = new(object_id, object_class, action)

    Delayed::Job.enqueue job, queue: 'remote_service_notifier'
  end

  def perform
    RestClient.post(url, params, content_type: 'application/json') { |response, request, result, &block|
      unless response.code == 201
        raise RemoteServiceNotifierError
      end
    }
  end

  private

  def url
    [
      REMOTE_SERVICE_NOTIFIER_PROTOCOL,
      '://',
      REMOTE_SERVICE_NOTIFIER_USERNAME,
      ':',
      REMOTE_SERVICE_NOTIFIER_PASSWORD,
      '@',
      REMOTE_SERVICE_NOTIFIER_HOST,
      REMOTE_SERVICE_NOTIFIER_PATH
    ].join
  end

  def params
    {
      notification: {
        sparc_id: object.id,
        kind: object.class.to_s,
        action: action,
        callback_url: object.remote_service_callback_url
      }
    }
  end

  def object
    @object ||= object_class.constantize.find object_id
  end
end
