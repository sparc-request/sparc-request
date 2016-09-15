FactoryGirl.define do
  factory :item do
    content 'string'
    item_type 'text'
    description 'text'
    required true
    questionnaire_id nil
  end
end
