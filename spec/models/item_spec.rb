require 'rails_helper'

RSpec.describe Item, type: :model do
  it { is_expected.to belong_to(:questionnaire) }

  it { is_expected.to validate_presence_of(:content) }

  it { is_expected.to validate_presence_of(:type) }

  it { is_expected.to validate_presence_of(:required) }
end
