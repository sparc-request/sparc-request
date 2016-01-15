require 'rails_helper'

RSpec.describe Portal::StudyTypeFinder do

  describe '.study_type' do

    let_there_be_lane
	  let_there_be_j
	  fake_login_for_each_test
	  build_service_request_with_study

    ##############ACTIVE STUDY##################
    context 'active study' do
      before do
        study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
      end

    	let(:study_type_finder) { Portal::StudyTypeFinder.new study }

      it 'should return a study_type of 0' do
        answer_questions(0, 0, nil, 1, 0, 0)
        expect(study_type_finder.study_type).to eq("0")
      end

      it 'should return a study_type of 1' do
        answer_questions(1, nil, nil, nil, nil, nil)
        expect(study_type_finder.study_type).to eq("1")
      end

      it 'should return a study_type of 2' do
        answer_questions(0, 1, 1, nil, nil, nil)
        expect(study_type_finder.study_type).to eq("2")
      end

      it 'should return a study_type of 3' do
        answer_questions(0, 1, 0, 0, 1, 1)
        expect(study_type_finder.study_type).to eq("3")
      end

      it 'should return a study_type of 4' do
        answer_questions(0, 1, 0, 0, 0, 1)
        expect(study_type_finder.study_type).to eq("4")
      end

      it 'should return a study_type of 5' do
        answer_questions(0, 1, 0, 0, 1, 0)
        expect(study_type_finder.study_type).to eq("5")
      end

      it 'should return a study_type of 6' do
        answer_questions(0, 1, 0, 0, 0, 0)
        expect(study_type_finder.study_type).to eq("6")
      end

      it 'should return a study_type of 7' do
        answer_questions(0, 1, 0, 1, 1, 1)
        expect(study_type_finder.study_type).to eq("7")
      end

      it 'should return a study_type of 8' do
        answer_questions(0, 1, 0, 1, 0, 1)
        expect(study_type_finder.study_type).to eq("8")
      end

      it 'should return a study_type of 9' do
        answer_questions(0, 1, 0, 1, 1, 0)
        expect(study_type_finder.study_type).to eq("9")
      end

      it 'should return a study_type of 10' do
        answer_questions(0, 1, 0, 1, 0, 0)
        expect(study_type_finder.study_type).to eq("10")
      end

      it 'should return a study_type of 11' do
        answer_questions(0, 0, nil, 0, 1, 1)
        expect(study_type_finder.study_type).to eq("11")
      end

      it 'should return a study_type of 12' do
        answer_questions(0, 0, nil, 0, 0, 1)
        expect(study_type_finder.study_type).to eq("12")
      end

      it 'should return a study_type of 13' do
        answer_questions(0, 0, nil, 0, 1, 0)
        expect(study_type_finder.study_type).to eq("13")
      end

      it 'should return a study_type of 14' do
        answer_questions(0, 0, nil, 0, 0, 0)
        expect(study_type_finder.study_type).to eq("14")
      end

      it 'should return a study_type of 15' do
        answer_questions(0, 0, nil, 1, 1, 1)
        expect(study_type_finder.study_type).to eq("15")
      end

      it 'should return a study_type of 16' do
        answer_questions(0, 0, nil, 1, 0, 1)
        expect(study_type_finder.study_type).to eq("16")
      end

      it 'should return a study_type of 17' do
        answer_questions(0, 0, nil, 1, 1, 0)
        expect(study_type_finder.study_type).to eq("17")
      end
    end



    ###########INACTIVE STUDY###################
    context 'inactive study' do
    	before do
    		study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:false).pluck(:id).first)
    	end

    	let(:study_type_finder) { Portal::StudyTypeFinder.new study }

      it 'should return a study_type of 0' do
        answer_questions(0, nil, nil, 1, 0, 0)
        expect(study_type_finder.study_type).to eq("0")
      end

      it 'should return a study_type of 1' do
        answer_questions(1, 1, nil, nil, nil, nil)
        expect(study_type_finder.study_type).to eq("1")
      end

      it 'should return a study_type of 2' do
        answer_questions(1, 0, 1, nil, nil, nil)
        expect(study_type_finder.study_type).to eq("2")
      end

    	it 'should return a study_type of 3' do
        answer_questions(1, 0, 0, 0, 1, 1)
    		expect(study_type_finder.study_type).to eq("3")
    	end

      it 'should return a study_type of 4' do
        answer_questions(1, 0, 0, 0, 0, 1)
        expect(study_type_finder.study_type).to eq("4")
      end

      it 'should return a study_type of 5' do
        answer_questions(1, 0, 0, 0, 1, 0)
        expect(study_type_finder.study_type).to eq("5")
      end

      it 'should return a study_type of 6' do
        answer_questions(1, 0, 0, 0, 0, 0)
        expect(study_type_finder.study_type).to eq("6")
      end

      it 'should return a study_type of 7' do
        answer_questions(1, 0, 0, 1, 1, 1)
        expect(study_type_finder.study_type).to eq("7")
      end

      it 'should return a study_type of 8' do
        answer_questions(1, 0, 0, 1, 0, 1)
        expect(study_type_finder.study_type).to eq("8")
      end

      it 'should return a study_type of 9' do
        answer_questions(1, 0, 0, 1, 1, 0)
        expect(study_type_finder.study_type).to eq("9")
      end

      it 'should return a study_type of 10' do
        answer_questions(1, 0, 0, 1, 0, 0)
        expect(study_type_finder.study_type).to eq("10")
      end

      it 'should return a study_type of 11' do
        answer_questions(0, nil, nil, 0, 1, 1)
        expect(study_type_finder.study_type).to eq("11")
      end

      it 'should return a study_type of 12' do
        answer_questions(0, nil, nil, 0, 0, 1)
        expect(study_type_finder.study_type).to eq("12")
      end

      it 'should return a study_type of 13' do
        answer_questions(0, nil, nil, 0, 1, 0)
        expect(study_type_finder.study_type).to eq("13")
      end

      it 'should return a study_type of 14' do
        answer_questions(0, nil, nil, 0, 0, 0)
        expect(study_type_finder.study_type).to eq("14")
      end

      it 'should return a study_type of 15' do
        answer_questions(0, nil, nil, 1, 1, 1)
        expect(study_type_finder.study_type).to eq("15")
      end

      it 'should return a study_type of 16' do
        answer_questions(0, nil, nil, 1, 0, 1)
        expect(study_type_finder.study_type).to eq("16")
      end

      it 'should return a study_type of 17' do
        answer_questions(0, nil, nil, 1, 1, 0)
        expect(study_type_finder.study_type).to eq("17")
      end
    end
  end

  def answer_questions(*answers)
    active_answer1.update_attributes(answer: answers[0])
    active_answer2.update_attributes(answer: answers[1])
    active_answer3.update_attributes(answer: answers[2])
    active_answer4.update_attributes(answer: answers[3])
    active_answer5.update_attributes(answer: answers[4])
    active_answer6.update_attributes(answer: answers[5])
  end
end
