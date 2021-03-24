# Copyright © 2011-2020 MUSC Foundation for Research Development
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

class ProtocolMailer < ActionMailer::Base
  helper ApplicationHelper
  helper NotifierHelper

  default from: Setting.get_value("no_reply_from")

  # https://www.pivotaltracker.com/story/show/161483270
  def archive_email
    @recipient            = params[:recipient]
    @protocol             = params[:protocol]
    @archiver             = params[:archiver]
    @action               = params[:action]
    @service_request      = @protocol.service_requests.first

    send_email(@recipient,
               t("mailers.protocol_mailer.archive_email.#{@action}.subject", protocol_id: @protocol.id))
  end

  def request_access_email
    @recipient            = params[:recipient]
    @protocol             = params[:protocol]
    @requester            = params[:requester]
    @service_request      = @protocol.service_requests.first

    send_email(@recipient,
               t("mailers.protocol_mailer.request_access_email.subject", requester: @requester.full_name, protocol_id: @protocol.id),
               @requester)
  end

  def merge_protocols_email
    @recipient         = params[:recipient]
    @protocol          = params[:protocol]
    @merged_id         = params[:merged_id]
    @service_request   = @protocol.service_requests.first

    send_email(@recipient,
               t("mailers.protocol_mailer.merge_protocols_email.subject", protocol_id: @protocol.id,  merged_id: @merged_id))
  end

  private

  def send_email(recipient, subject, cc=nil)
    unless recipient.imported_from_lbb
      @send_to = recipient

      mail(to: recipient.email, subject: subject, cc: cc.try(:email))
    end
  end
end
