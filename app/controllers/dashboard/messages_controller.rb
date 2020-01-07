# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  def index
    @notification = Notification.find(params[:notification_id])
    recipient     = @notification.get_user_other_than(current_user)
    @read_by_user = @notification.read_by?(current_user)
    @notification.set_read_by current_user unless @read_by_user
    @messages     = @notification.messages
    @message      = Message.new(notification: @notification, sender: current_user, recipient: recipient)

    respond_to :js
  end

  def new
    @notification = Notification.find(params[:notification_id])
    recipient = @notification.get_user_other_than(current_user)
    @message = Message.new(notification_id: @notification.id, to: recipient.id,
      from: current_user.id)

    respond_to :js
  end

  def create
    @notification = Notification.find(params[:message][:notification_id])
    @message      = Message.new(message_params)
    if @message.save
      recipient = @message.recipient
      @notification.set_read_by(recipient, false)
      UserMailer.notification_received(recipient, @notification.sub_service_request, current_user).deliver unless recipient.email.blank?

      @messages = @notification.messages
      @message  = Message.new(notification: @notification, sender: current_user, recipient: recipient)
    else
      @errors = @message.errors
    end

    respond_to :js
  end

  private

  def message_params
    params.require(:message).permit(:notification_id, :to, :from, :email, :body)
  end
end
