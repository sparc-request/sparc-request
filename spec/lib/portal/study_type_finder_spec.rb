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
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("0")
      end

      it 'should return a study_type of 1' do
        active_answer1.update_attributes(answer: 1)
        active_answer2.update_attributes(answer: nil)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: nil)
        active_answer5.update_attributes(answer: nil)
        active_answer6.update_attributes(answer: nil)

        expect(study_type_finder.study_type).to eq("1")
      end

      it 'should return a study_type of 2' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 1)
        active_answer4.update_attributes(answer: nil)
        active_answer5.update_attributes(answer: nil)
        active_answer6.update_attributes(answer: nil)

        expect(study_type_finder.study_type).to eq("2")
      end

      it 'should return a study_type of 3' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("3")
      end

      it 'should return a study_type of 4' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("4")
      end

      it 'should return a study_type of 5' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("5")
      end

      it 'should return a study_type of 6' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("6")
      end

      it 'should return a study_type of 7' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("7")
      end

      it 'should return a study_type of 8' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("8")
      end

      it 'should return a study_type of 9' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("9")
      end

      it 'should return a study_type of 10' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("10")
      end

      it 'should return a study_type of 11' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("11")
      end

      it 'should return a study_type of 12' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("12")
      end
      it 'should return a study_type of 13' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("13")
      end

      it 'should return a study_type of 14' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("14")
      end

      it 'should return a study_type of 15' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("15")
      end

      it 'should return a study_type of 16' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("16")
      end

      it 'should return a study_type of 17' do
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 0)

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
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("0")
      end

      it 'should return a study_type of 1' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 1)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: nil)
        answer5.update_attributes(answer: nil)
        answer6.update_attributes(answer: nil)

        expect(study_type_finder.study_type).to eq("1")
      end

      it 'should return a study_type of 2' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 1)
        answer4.update_attributes(answer: nil)
        answer5.update_attributes(answer: nil)
        answer6.update_attributes(answer: nil)

        expect(study_type_finder.study_type).to eq("2")
      end

    	it 'should return a study_type of 3' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 1)

    		expect(study_type_finder.study_type).to eq("3")
    	end

      it 'should return a study_type of 4' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("4")
      end

      it 'should return a study_type of 5' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("5")
      end

      it 'should return a study_type of 6' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("6")
      end

      it 'should return a study_type of 7' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("7")
      end

      it 'should return a study_type of 8' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("8")
      end

      it 'should return a study_type of 9' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("9")
      end

      it 'should return a study_type of 10' do
        answer1.update_attributes(answer: 1)
        answer2.update_attributes(answer: 0)
        answer3.update_attributes(answer: 0)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("10")
      end

      it 'should return a study_type of 11' do
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("11")
      end

      it 'should return a study_type of 12' do
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("12")
      end
      it 'should return a study_type of 13' do
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("13")
      end

      it 'should return a study_type of 14' do
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 0)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("14")
      end

      it 'should return a study_type of 15' do
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("15")
      end

      it 'should return a study_type of 16' do
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 0)
        answer6.update_attributes(answer: 1)

        expect(study_type_finder.study_type).to eq("16")
      end

      it 'should return a study_type of 17' do
        answer1.update_attributes(answer: 0)
        answer2.update_attributes(answer: nil)
        answer3.update_attributes(answer: nil)
        answer4.update_attributes(answer: 1)
        answer5.update_attributes(answer: 1)
        answer6.update_attributes(answer: 0)

        expect(study_type_finder.study_type).to eq("17")
      end
    end
  end
end
