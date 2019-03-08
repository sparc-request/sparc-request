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

module ProtocolsHelper

  def display_study_type_question?(protocol, study_type_answer, view_protocol=false)
    if !Setting.get_value("use_epic") || protocol.selected_for_epic == false
      # If read-only (Dashboard--> 'Edit Study Information' or 'View Study Details') do not show the first CofC question if unanswered
      if view_protocol
        ['certificate_of_conf_no_epic', 'higher_level_of_privacy_no_epic'].include?(study_type_answer.study_type_question.friendly_id) && study_type_answer.answer != nil
      else # Else we want to always display the first CofC question regardless of whether it's been answered or needs to be answered
        if study_type_answer.study_type_question.friendly_id == 'certificate_of_conf_no_epic'
          true
        else # We want to see the second CofC question if it's been answered or if the first COFC answer is "No"
          if study_type_answer.study_type_question.friendly_id == 'higher_level_of_privacy_no_epic'
            protocol.display_answers.joins(:study_type_question).where(study_type_questions: { friendly_id: 'certificate_of_conf_no_epic'}).first.try(:answer) == false
          else
            false
          end
        end
      end
    else
      !['certificate_of_conf_no_epic', 'higher_level_of_privacy_no_epic'].include?(study_type_answer.study_type_question.friendly_id) && study_type_answer.answer != nil
    end
  end

  def display_readonly_answer(answer)
    if answer == true
      'Yes'
    elsif answer == false
      'No'
    else
      nil
    end
  end

  def display_rmid_validated_protocol(protocol, option)
    if Setting.get_value("research_master_enabled")
      if protocol.rmid_validated?
        content_tag(
          :h6,
          t("protocols.summary.rmid_validated", title: option),
          class: "text-success"
        )
      end
    end
  end

  # If USE_EPIC is false and any of the CofC questions have been answered, display them OR
  # If USE_EPIC is true and any of the Epic questions have been answered, display them
  def display_readonly_study_type_questions?(protocol)
    (Setting.get_value("use_epic") && protocol.display_answers.where.not(answer: nil).any?) || (!Setting.get_value("use_epic") && protocol.active? && protocol.display_answers.joins(:study_type_question).where(study_type_questions: { friendly_id: ['certificate_of_conf_no_epic', 'higher_level_of_privacy_no_epic'] }).where.not(answer: nil).any?)
  end
end
