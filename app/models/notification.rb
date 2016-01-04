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
  belongs_to :other_user, :class_name => "Identity"
  belongs_to :sub_service_request

  has_many :messages

  attr_accessible :sub_service_request_id
  attr_accessible :originator_id
  attr_accessible :other_user_id
  attr_accessible :read_by_originator
  attr_accessible :read_by_other_user

  def read_by? user
    # has this notification been read by this user?
    case user.id
    when originator_id
      return read_by_originator == true
    when other_user_id
      return read_by_other_user == true
    else
      return false
    end
  end

  def set_read_by user, read=true
    # this notification been read by this user
    case user.id
    when originator_id
      return self.update_attributes(read_by_originator: read)
    when other_user_id
      return self.update_attributes(read_by_other_user: read)
    else
      return false
    end
  end

  def from
    unless messages.empty?
      messages.last.sender
    else
      originator
    end
  end

  def to
    unless messages.empty?
      messages.last.recipient
    else
      other_user
    end
  end

  def get_users
    # get the users associated with this notification
    return [originator, other_user]
  end

  def get_user_other_than current_user
    # given one user associated with this notification, return the other user
    users = get_users
    if users.include? current_user #current_user is associated with this notification
      return (users - [current_user]).first
    else #current_user is not associated with this notification
      return nil
    end
  end
end
