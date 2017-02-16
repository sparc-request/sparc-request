require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  it { is_expected.to belong_to(:service) }

  it { is_expected.to have_many(:items) }

  it { is_expected.to accept_nested_attributes_for(:items) }

  it { is_expected.to validate_presence_of(:name) }

  describe 'check the length of association' do
    it 'should be invalid if it has no items' do
      questionnaire = build(:questionnaire)

      result = questionnaire.valid?

      expect(result).to eq false
      expect(questionnaire.errors[:_]).to include(
        'At least one question must exist in order to create a form.'
      )
    end
  end
end

