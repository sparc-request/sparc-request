# Copyright © 2011 MUSC Foundation for Research Development
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

class Notification < ActiveRecord::Base
  audited

  belongs_to :originator, :class_name => "Identity"
  belongs_to :sub_service_request

  has_many :messages

  attr_accessible :sub_service_request_id
  attr_accessible :originator_id

  def read_by_user_id? user_id
    # have all messages in this notification to this user been read?
    messages_to_user = messages.where("`to` = #{user_id}")
    if messages_to_user.all?{ |m| m.read }
      return true
    else
      return false
    end
  end

  def get_users
    # get the users associated with this notification
    users = []
    unless messages.empty?
      one_message = messages.first
      users = [one_message.sender, one_message.recipient]
    else
      users << originator
    end

    return users
  end

  def get_other_user current_id
    # given one user id associated with this notification, return the other user instance
    users = get_users
    if users.map(&:id).include? current_id
      return users.select{ |u| u.id != current_id }.first
    else
      return nil
    end
  end
end
