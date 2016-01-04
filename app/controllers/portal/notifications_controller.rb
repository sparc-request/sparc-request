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

class Portal::NotificationsController < Portal::BaseController
  respond_to :html, :json

  def index
    respond_to do |format|
      format.html {
        @notification_index = true
        @notifications = @user.all_notifications
        respond_with @user, @notifications
      }
      format.json {
        @table = params[:table]
        ssr_id = params[:sub_service_request_id].to_i
        @notifications = @user.all_notifications.select!{ |n| n.sub_service_request_id == ssr_id }
        if @table == "inbox"
          # return list of notifications with any messages to current user
          @notifications.select!{ |n| n.messages.any? { |m| m.to == @user.id }}
        elsif @table == "sent"
          # return list of notifications with any messages from current user
          @notifications.select!{ |n| n.messages.any? { |m| m.from == @user.id }}
        end
      }
    end
  end

  def new
    @recipient = Identity.find(params[:identity_id])
    @is_service_provider = params[:is_service_provider]
    @notification = Notification.new(originator_id: @user.id, sub_service_request_id: params[:sub_service_request_id])
    @message = @notification.messages.new(to: @recipient.id, from: @user.id, email: @recipient.try(:email))
  end

  def create
    is_service_provider = params[:is_service_provider]
    @notification = Notification.new(originator_id: params[:notification][:originator_id], sub_service_request_id: params[:notification][:sub_service_request_id])
    @message = @notification.messages.new(params[:notification][:message])
    if @message.valid?
      @notification.save
      @message.save
      @notifications = @user.all_notifications.where(:sub_service_request_id => @notification.sub_service_request_id)
      ssr_id = @notification.sub_service_request_id.to_s
      UserMailer.notification_received(@message.recipient, is_service_provider, ssr_id).deliver unless @message.recipient.email.blank?
      flash[:success] = "Notification Sent!"
    else
      @errors = @message.errors
    end
  end

  def mark_as_read
    # handles marking notification messages as read or unread
    as_read = (params[:read] == "true") #could be 'true'(read) or 'false'(unread)
    params[:notification_ids].each do |notification_id|
      notification = Notification.find(notification_id)
      notification.set_read_by @user, as_read
    end
  end

  def user_portal_update
    @notification = Notification.find(params[:id])

    # TODO: @message is not set here; is that correct?
    @message = @notification.messages.create(params[:message])

    if @message.valid?
      @message.save
      # TODO: this is not set if no message is created; is that correct?
      @notifications = @user.all_notifications

      ssr_id = @notification.sub_service_request.id.to_s
      @is_service_provider =  !@notification.sub_service_request.organization.service_providers.where(:identity_id => @message.recipient.id).empty?
      is_service_provider = @is_service_provider.to_s

      UserMailer.notification_received(@message.recipient, is_service_provider, ssr_id).deliver unless @message.recipient.email.blank?
    end
    respond_to do |format|
      format.js { render 'portal/notifications/create' }
    end
  end

  def admin_update
    @notification = Notification.find(params[:id])
    @message = @notification.messages.create(params[:message])

    if @message.valid?
      @message.save
      # @notification.reload
      @sub_service_request = @notification.sub_service_request
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
      UserMailer.notification_received(@message.recipient).deliver unless @message.recipient.email.blank?
    end
    respond_to do |format|
      format.js
      format.html
    end
  end
end
