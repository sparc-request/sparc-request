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

desc "add new study type questions"
task :add_new_study_type_questions => :environment do
	friendly_ids = ['certificate_of_conf', 'higher_level_of_privacy', 'access_study_info', 'epic_inbasket', 'research_active', 'restrict_sending']

	study_type_questions_version_2 = ["1. Does your study have a Certificate of Confidentiality?", 
	                                 "2. Does your study require a higher level of privacy for the participants?",
	                                 "2b. Do participants enrolled in your study require a second DEIDENTIFIED Medical Record that is not connected to their primary record in Epic?",
	                                 "3. Do you wish to receive a notification via Epic InBasket when your research participants are admitted to the hospital or ED?",
	                                 "4. Do you wish to remove the 'Research: Active' indicator in the Patient Header for your study participants?",
	                                 "5. Do you need to restrict the sending of study related results, such as laboratory and radiology results, to a participants MyChart?"]
  study_type_questions_version_2.each_with_index do |stq, index|
    StudyTypeQuestion.create(order: index + 1, question: stq, friendly_id: friendly_ids[index], study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)
  end
end
