# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module EmailHelpers

  def does_not_have_a_reminder_note(mail_response)
    expect(mail_response).not_to have_xpath "//p[text()='*Note(s) are included with this submission.']"
  end

  def does_have_a_reminder_note(mail_response)
    expect(mail_response).to have_xpath "//p[text()='*Note(s) are included with this submission.']"
  end

  def does_not_have_a_submission_reminder(mail_response)
    expect(mail_response).not_to have_xpath "//p[text()='*Note: upon submission, services selected to go to Epic will be sent daily at 4:30pm.']"
  end

  def does_have_a_submission_reminder(mail_response)
    expect(mail_response).to have_xpath "//p[text()='*Note: upon submission, services selected to go to Epic will be sent daily at 4:30pm.']"
  end

  def get_a_cost_estimate_does_not_have_notes(mail_response)
    does_not_have_a_reminder_note(mail_response)
    does_not_have_a_submission_reminder(mail_response)
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end