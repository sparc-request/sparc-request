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
require 'rails_helper'

RSpec.describe Protocol, type: :model do
  build_study_type_question_groups()
  build_study_type_questions()

  let!(:study) { create(:study_federally_funded, selected_for_epic: true, study_type_question_group_id: StudyTypeQuestionGroup.active.ids.first) }

  build_study_type_answers()

  stub_config("use_epic", true)
  
  describe 'should validate study_type_answers for study' do
    it 'should not add errors if the first answer is true' do
      answers = [true, nil, nil, nil, nil]
      update_answers(answers)
      study.validate_study_type_answers
      expect(study.errors.messages).to eq({})
      expect(study).to be_valid
    end

    it 'should not add errors if all questions are answered' do
      answers = [false, false, true, true, true]
      update_answers(answers)
      study.validate_study_type_answers
      expect(study.errors.messages).to eq({})
      expect(study).to be_valid
    end

    it 'should add errors if questions are left unanswered' do
      answers = [false, nil, nil, nil, nil]
      update_answers(answers)
      study.validate_study_type_answers
      expect(study.errors.messages).to eq({:study_type_answers=>[{"higher_level_of_privacy"=>"can't be blank"}]})
      expect(study).not_to be_valid
    end

    it 'should add errors if questions are left unanswered' do
      answers = [false, true, nil, nil, nil]
      update_answers(answers)
      study.validate_study_type_answers
      expect(study.errors.messages).to eq({:study_type_answers=>[{"epic_inbasket"=>"can't be blank"}]})
      expect(study).not_to be_valid
    end

    it 'should add errors if questions are left unanswered' do
      answers = [false, true, false, nil, nil]
      update_answers(answers)
      study.validate_study_type_answers
      expect(study.errors.messages).to eq({:study_type_answers=>[{"research_active"=>"can't be blank"}]})
      expect(study).not_to be_valid
    end

    it 'should add errors if questions are left unanswered' do
      answers = [false, true, false, true, nil]
      update_answers(answers)
      study.validate_study_type_answers
      expect(study.errors.messages).to eq({:study_type_answers=>[{"restrict_sending"=>"can't be blank"}]})
      expect(study).not_to be_valid
    end

    it 'should add errors if all questions are left unanswered' do
      answers = [nil, nil, nil, nil, nil]
      update_answers(answers)
      study.validate_study_type_answers
      expect(study.errors.messages).to eq({:study_type_answers=>[{"certificate_of_conf"=>"can't be blank"}]})
      expect(study).not_to be_valid
    end
  end

  def update_answers (answer_array)
    answer1_version_3.update_attributes(answer: answer_array[0])
    answer2_version_3.update_attributes(answer: answer_array[1])
    answer3_version_3.update_attributes(answer: answer_array[2])
    answer4_version_3.update_attributes(answer: answer_array[3])
    answer5_version_3.update_attributes(answer: answer_array[4])
  end
end
