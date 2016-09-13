require 'rails_helper'

RSpec.describe Submission, type: :model do
  it { is_expected.to belong_to(:service) }

  it { is_expected.to belong_to(:identity) }

  it { is_expected.to have_many(:questionnaire_responses) }

  it { is_expected.to accept_nested_attributes_for(:questionnaire_responses) }
end
