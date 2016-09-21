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

class Dashboard::NotificationsController < Dashboard::BaseController
  respond_to :html, :json

  def index
    session[:breadcrumbs].
      add_crumbs(notifications: true).
      clear(:edit_protocol)

    @table = params[:table]

    @notifications =
      if @table == 'inbox'
        Notification.in_inbox_of(@user.id, params[:sub_service_request_id])
      else
        Notification.in_sent_of(@user.id, params[:sub_service_request_id])
      end.uniq
  end

  def new
    @sub_service_request_id = params[:sub_service_request_id]

    if params[:identity_id]
      if @sub_service_request_id.present?
        @sub_service_request = SubServiceRequest.find(@sub_service_request_id)
        @notification = @sub_service_request.notifications.new
      else
        @notification = Notification.new
      end

      if params[:identity_id].try(:to_i) == current_user.id
        @notification.errors.add(:notifications, "can't be sent to yourself.")
        @errors = @notification.errors
      end

      @message = @notification.messages.new(to: params[:identity_id])
    end
  end

  def create
    message_params = params[:notification].delete(:message)
    if message_params[:to].present?
      @recipient = Identity.find(message_params[:to])
      @notification = Notification.new(params[:notification].merge(originator_id: @user.id, read_by_originator: true, other_user_id: @recipient.id, read_by_other_user: false))
      @message = @notification.messages.new(message_params.merge(from: @user.id, email: @recipient.email))
      if @message.valid?
        @notification.save
        @message.save

        ssr = @notification.sub_service_request
        @notifications = Notification.belonging_to(@user.id, params[:sub_service_request_id])

        UserMailer.notification_received(@recipient, ssr).deliver unless @recipient.email.blank?
        flash[:success] = 'Notification Sent!'
      else
        @errors = @message.errors
      end
    end
  end

  def mark_as_read
    # handles marking notification messages as read or unread
    as_read = (params[:read] == 'true') #could be 'true'(read) or 'false'(unread)
    Notification.where(id: params[:notification_ids]).each { |n| n.set_read_by(@user, as_read)}

    if params[:sub_service_request_id]
      @unread_notification_count_for_ssr = @user.unread_notification_count(params[:sub_service_request_id])
    end

    @unread_notification_count = @user.unread_notification_count
  end
end
