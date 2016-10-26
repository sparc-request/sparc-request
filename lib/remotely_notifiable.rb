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

module RemotelyNotifiable

  extend ActiveSupport::Concern

  included do
    after_create  :notify_remote_after_create,  if: :notify_remote_after_create?
    around_update :notify_remote_around_update, if: :notify_remote_around_update?
    after_destroy :notify_remote_after_destroy, if: :notify_remote_after_destroy?
  end

  def remote_service_callback_url
    if self.persisted?
      "#{REMOTE_SERVICE_NOTIFIER_PROTOCOL}://#{HOST}/#{CURRENT_API_VERSION}/#{self.class.to_s.pluralize.underscore}/#{self.id}.json"
    end
  end

  private

  # Default to false
  def notify_remote_after_create?
    false
  end

  # Default to false
  def notify_remote_around_update?
    false
  end

  # Default to false
  def notify_remote_after_destroy?
    false
  end

  # Default to all attributes
  def remotely_notifiable_attributes_to_watch_for_change
    attributes.keys
  end

  def notify_remote_after_create
    RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'create')
  end

  def qualifying_changes_detected?
    (remotely_notifiable_attributes_to_watch_for_change & changed).any?
  end

  def notify_remote_around_update
    yield

    if qualifying_changes_detected?
      RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'update')
    end
  end

  def notify_remote_after_destroy
    RemoteServiceNotifierJob.enqueue(self.id, self.class.name, 'destroy')
  end
end
