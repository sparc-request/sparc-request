require 'date'
require 'rails_helper'

RSpec.describe 'Study' do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe "#activate" do

    context "activate an inactive study" do
      before :each do
        study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:false).pluck(:id).first)
        study.activate
      end

      it "should return true" do
        expect(study.active?).to eq true
      end
    end
    context "activate an active study" do
      before :each do
        study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
        study.activate
      end

      it "should return true" do
        expect(study.active?).to eq true
      end
    end
  end
end