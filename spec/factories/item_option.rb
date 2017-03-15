FactoryGirl.define do
  factory :item_option do
    content 'text'
    validate_content true
    item_id nil
  end
end
