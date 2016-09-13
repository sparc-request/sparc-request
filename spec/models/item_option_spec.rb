require 'rails_helper'

RSpec.describe ItemOption, type: :model do
  it { is_expected.to belong_to(:item) }
end
