require 'rails_helper'

RSpec.describe ItemOption, type: :model do
  it { is_expected.to belong_to(:item) }

  it 'should validate presence if validate_content is true' do
    item_option = build(:item_option, content: nil, validate_content: true)

    expect(item_option).not_to be_valid
  end

  it 'should carry along if validate_content is false' do
    item_option = build(:item_option, content: nil, validate_content: false)

    expect(item_option).to be_valid
  end
end

