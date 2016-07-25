require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  it { is_expected.to belong_to(:service) }

  it { is_expected.to have_many(:items) }

  it { is_expected.to accept_nested_attributes_for(:items) }
end
