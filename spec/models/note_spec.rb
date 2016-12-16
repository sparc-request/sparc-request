require 'rails_helper'

RSpec.describe Note, type: :model do

  it { is_expected.to belong_to(:identity) }

  it { is_expected.to belong_to(:notable) }

  it { is_expected.to validate_presence_of(:body) }

  it { is_expected.to validate_presence_of(:identity_id) }
end

