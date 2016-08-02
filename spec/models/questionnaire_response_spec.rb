require 'rails_helper'

RSpec.describe QuestionnaireResponse, type: :model do
  it { is_expected.to belong_to(:submission) }

  it { is_expected.to belong_to(:item) }
end
