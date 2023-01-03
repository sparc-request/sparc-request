# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

namespace :update_study_type_question_text do
  desc "TODO"
  task change_question_task: :environment do
    @stq = StudyTypeQuestion.where(friendly_id: "certificate_of_conf").second
    @stq.update(question: "1. Does your Informed Consent contain IRB standard language describing the use of an <a target='_blank' href='https://research.musc.edu/resources/ori/irb/forms/consent-language/certificate-of-confidentiality/alias'>Alias Medical Record</a>? If Yes, the PI is responsible for consulting with the Epic Research Team to establish the process for creating alias identities (de-identification) for your study participants.")

    @stq2 = StudyTypeQuestion.where(friendly_id: "higher_level_of_privacy").third
    @stq2.update(question: "2. Does your study require a higher level of privacy protection for the participants? <br> (Your study needs \"break the glass\" functionality in Epic because it is collecting sensitive data, such as HIV/sexually transmitted disease, sexual practice/attitudes, illegal substance, etc., which needs higher privacy protection, yet not complete de-identification of the study participant.)")
  end

end
