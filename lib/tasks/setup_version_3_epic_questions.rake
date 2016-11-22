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

desc "setup version 3 epic questions"
task :setup_version_3_epic_questions => :environment do
  friendly_ids = ['certificate_of_conf', 'higher_level_of_privacy', 'epic_inbasket', 'research_active', 'restrict_sending']

  study_type_questions_version_3 = ["1. Does your Informed Consent provide information to the participant specifically stating their study participation be kept private from anyone outside the research team? (i.e. your study has a Certificate of Confidentiality or involves sensitive data collection which requires de-identification of the research participant in Epic.)",
                               "2. Does your study require a higher level of privacy protection for the participants? (Your study needs 'break the glass' functionality in Epic because it is collection sensitive data, such as HIV/sexually transmitted disease, sexual practice/attitudes, illegal substance, etc., which needs higher privacy protection, yet not complete de-identification of the study participant.)",
                               "3. Is it appropriate for study team members to receive Epic InBasket notifications if research participants in this study are hospitalized or admitted to the Emergency Department?",
                               "4. Is it appropriate to display the pink 'Research:Active indicator in the Patient Header for all study participants?'",
                               "5. Is it appropriate for all study participants to receive associated test results, such as labs and/or imaging findings, via MyChart?"]
  study_type_questions_version_3.each_with_index do |stq, index|
    StudyTypeQuestion.create(order: index + 1, question: stq, friendly_id: friendly_ids[index], study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)
  end
end
