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

class SurveyNotification < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def system_satisfaction_survey(response)
    @response = response
    @identity = Identity.find(response.identity_id)
    email     = Setting.get_value("admin_mail_to")
    cc        = Setting.get_value("system_satisfaction_survey_cc")
    subject   = t('surveyor.responses.emails.system_satisfaction.subject', site_name: t(:proper)[:header])

    mail(to: email, cc: cc, from: @identity.email, subject: subject)
  end

  def service_survey(surveys, identity, ssr)
    @identity   = identity
    @ssr        = ssr
    @surveys    = surveys
    email       = @identity.email
    subject     = t('surveyor.responses.emails.service_survey.subject', site_name: t(:proper)[:header], ssr_id: @ssr.display_id)

    mail(to: email, from: Setting.get_value("no_reply_from"), subject: subject)
  end

end
