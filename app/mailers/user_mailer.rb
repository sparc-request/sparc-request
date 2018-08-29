# Copyright © 2011-2018 MUSC Foundation for Research Development
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

class UserMailer < ActionMailer::Base
  default :from => Setting.get_value("no_reply_from")

  def authorized_user_changed(user, protocol, modified_role, action)
    @action = action
    @modified_role = modified_role
    @send_to = user
    @protocol = protocol
    @protocol_link = Setting.get_value("dashboard_link") + "/protocols/#{@protocol.id}"

    send_message(t('mailer.email_title.general', email_status: "Authorized Users Update", type: "Protocol", id: @protocol.id))
  end

  def notification_received(user, ssr)
    @send_to = user

    if ssr.present?
      is_service_provider = @send_to.is_service_provider?(ssr)
      send_message("#{t(:mailer)[:email_title][:new]} #{t('mailer.email_title.general', email_status: 'Notification', type: 'Protocol', id: ssr.protocol.id)}", is_service_provider, ssr.id.to_s)
    else
      send_message("#{t(:mailer)[:email_title][:new]} #{t('mailer.email_title.general', email_status: 'Notification', type: 'Protocol', id: ssr.protocol.id)}")
    end
  end

  private

  def send_message subject, is_service_provider='false', ssr_id=''
    email = @send_to.email
    @is_service_provider = is_service_provider
    @ssr_id = ssr_id

    mail(:to => email, :subject => subject)
  end

end
