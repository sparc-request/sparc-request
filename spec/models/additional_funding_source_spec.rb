require 'rails_helper'

RSpec.describe AdditionalFundingSource, type: :model do
  it { should belong_to(:protocol) }
end
