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
require 'rails_helper'

RSpec.describe 'Protocol' do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study()
  build_study_type_question_groups()
  build_study_type_questions()
  build_study_type_answers()

  before :each do 
    study.update_attribute(:selected_for_epic, true)
  end

  describe 'should return a study_type note' do
    it 'should return study_type 1 note' do
      answers = [true, nil, nil, nil, nil]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('De-identified Research Participant')
    end

    it 'should return study_type 3 note' do
      answers = [false, true, false, false, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters')
    end

    it 'should return study_type 4 note' do
      answers = [false, true, false, true, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: no notification, pink header, no MyChart access.')
    end

    it 'should return study_type 5 note' do
      answers = [false, true, false, false, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: no notification, no pink header, MyChart access.')
    end

    it 'should return study_type 5 note' do
      answers = [false, true, false, false, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: no notification, no pink header, MyChart access.')
    end

    it 'should return study_type 6 note' do
      answers = [false, true, false, true, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: no notification, pink header, MyChart access.')
    end

    it 'should return study_type 7 note' do
      answers = [false, true, true, false, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: notification, no pink header, no MyChart access.')
    end

    it 'should return study_type 8 note' do
      answers = [false, true, true, true, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: notification, pink header, no MyChart access.')
    end

    it 'should return study_type 9 note' do
      answers = [false, true, true, false, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: notification, no pink header, MyChart access.')
    end

    it 'should return study_type 10 note' do
      answers = [false, true, true, true, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Break-The-Glass for research associated encounters: notification, pink header, MyChart access.')
    end

    it 'should return study_type 11 note' do
      answers = [false, false, false, false, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  no notification, no pink header, no MyChart access.')
    end

    it 'should return study_type 12 note' do
      answers = [false, false, false, true, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  no notification, pink header, no MyChart access.')
    end

    it 'should return study_type 13 note' do
      answers = [false, false, false, false, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  no notification, no pink header, MyChart access.')
    end

    it 'should return study_type 14 note' do
      answers = [false, false, false, true, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  no notification, pink header, MyChart access.')
    end

    it 'should return study_type 15 note' do
      answers = [false, false, true, false, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  notification, no pink header, no MyChart access.')
    end

    it 'should return study_type 16 note' do
      answers = [false, false, true, true, false]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  notification, pink header, no MyChart access.')
    end

    it 'should return study_type 17 note' do
      answers = [false, false, true, false, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  notification, no pink header, MyChart access.')
    end

    it 'should return study_type 0 note' do
      answers = [false, false, true, true, true]
      update_answers(answers)
      expect(study.determine_study_type_note).to eq('Full Epic Functionality:  notification, pink header, MyChart access.')
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