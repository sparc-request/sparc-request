require 'rails_helper'

RSpec.describe QuestionnaireResponse, type: :model do
  it { is_expected.to belong_to(:submission) }

  it { is_expected.to belong_to(:item) }

  describe '#required?' do
    it 'should validate presence if required is true' do
      questionnaire_response = build(:questionnaire_response, content: '', required: true)

      expect(questionnaire_response).not_to be_valid
    end
    it 'should validate presence if required is true' do
      questionnaire_response = build(:questionnaire_response, content: 'content', required: true)

      expect(questionnaire_response).to be_valid
    end
  end
end
