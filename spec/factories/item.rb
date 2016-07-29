FactoryGirl.define do
  factory :item do
    content 'string'
    type 'text'
    description 'text'
    required true
    questionnaire_id nil
  end
end
