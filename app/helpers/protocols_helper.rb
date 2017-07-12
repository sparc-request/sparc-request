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

module ProtocolsHelper
  def display_study_type_question?(protocol, study_type_answer, view_protocol=false)
    if !USE_EPIC || protocol.selected_for_epic == false
      # If read-only (Dashboard--> 'Edit Study Information' or 'View Study Details') do not show the first CofC question if unanswered
      if view_protocol
        ['certificate_of_conf_no_epic', 'higher_level_of_privacy_no_epic'].include?(study_type_answer.study_type_question.friendly_id) && study_type_answer.answer != nil
      else # Else we want to always display the first CofC question regardless of whether it's been answered or needs to be answered
        if study_type_answer.study_type_question.friendly_id == 'certificate_of_conf_no_epic'
          true
        else # We want to see the second CofC question if it's been answered
          ['higher_level_of_privacy_no_epic'].include?(study_type_answer.study_type_question.friendly_id) && study_type_answer.answer != nil
        end
      end
    else
      !['certificate_of_conf_no_epic', 'higher_level_of_privacy_no_epic'].include?(study_type_answer.study_type_question.friendly_id) && study_type_answer.answer != nil
    end
  end

  def display_rmid_validated_protocol(protocol, option)
    if protocol.rmid_validated?
      content_tag(
        :h6,
        t("protocols.summary.rmid_validated", title: option),
        class: "text-success"
      )
    end
  end
end
