require 'rails_helper'

RSpec.describe Item, type: :model do
  it { is_expected.to belong_to(:questionnaire) }

  it { is_expected.to have_many(:questionnaire_responses) }

  it { is_expected.to have_many(:item_options) }

  it { is_expected.to accept_nested_attributes_for(:item_options) }

  it { is_expected.to validate_presence_of(:content) }

  it { is_expected.to validate_presence_of(:item_type) }
end
