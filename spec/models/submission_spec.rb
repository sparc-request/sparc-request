require 'rails_helper'

RSpec.describe Submission, type: :model do
  it { is_expected.to belong_to(:service) }

  it { is_expected.to belong_to(:identity) }
end
