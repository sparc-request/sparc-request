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

class ProtocolMailer < ActionMailer::Base
  helper ApplicationHelper
  helper NotifierHelper

  default from: Setting.get_value("no_reply_from")

  # https://www.pivotaltracker.com/story/show/161483270
  def archive_email
    @protocol             = params[:protocol]
    @archiver             = params[:archiver]
    @action               = params[:action]
    @service_request      = @protocol.service_requests.first
    @ssrs_to_be_displayed = @protocol.sub_service_requests.where.not(status: Setting.get_value('finished_statuses') << 'draft')

    archive_email_recipients.each do |recipient|
      send_email(recipient, t("mailers.protocol_mailer.archive_email.#{@action}.subject", protocol_id: @protocol.id))
    end
  end

  private

  def send_email(recipient, subject)
    @send_to = recipient

    mail(to: recipient.email, subject: subject)
  end

  def archive_email_recipients
    (@protocol.identities + @ssrs_to_be_displayed.map(&:candidate_owners).flatten).uniq
  end
end
