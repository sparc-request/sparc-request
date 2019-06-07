# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

desc "change data in version 3 of epic questions"
task :study_type_question_3_fix => :environment do
  
  STUDY_TYPE_QUESTIONS_VERSION_3.each_with_index do |stq, index|
    question = StudyTypeQuestion.where(study_type_question_group_id: 3).find_or_create_by(question: stq)

    unless StudyTypeAnswer.where(study_type_question: question).any?
      Protocol.joins(:study_type_question_group).where(study_type_question_groups: { version: 3 }).all.each do |protocol|
        protocol.study_type_answers.create(study_type_question: question)
      end
    end
  end
  
  StudyTypeQuestion.where(question: STUDY_TYPE_QUESTIONS_VERSION_3[5]).update(order: 6, friendly_id: 'certificate_of_conf_no_epic')
  StudyTypeQuestion.where(question: STUDY_TYPE_QUESTIONS_VERSION_3[6]).update(order: 7, friendly_id: 'higher_level_of_privacy_no_epic')
end