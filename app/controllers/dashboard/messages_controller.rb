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

class Dashboard::MessagesController < Dashboard::BaseController
  respond_to :html, :json

  def index
    @notification = Notification.find(params[:notification_id])
    @read_by_user = @notification.read_by?(@user)
    @notification.set_read_by @user unless @read_by_user
    @messages = @notification.messages
  end

  def new
    @notification = Notification.find(params[:notification_id])
    recipient = @notification.get_user_other_than(@user)
    @message = Message.new(notification_id: @notification.id, to: recipient.id,
      from: @user.id, email: recipient.email)
  end

  def create
    @notification = Notification.find(params[:message][:notification_id])
    if message_params[:body].present? # don't create empty messages
      @message = Message.create(message_params)
      @notification.set_read_by(Identity.find(@message.to), false)
    end
    @messages = @notification.messages
  end

private

  def message_params
    params.require(:message).permit(:notification_id, :to, :from, :email, :body)
  end
end
