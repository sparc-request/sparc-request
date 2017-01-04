FactoryGirl.define do
  factory :item do
    content { Faker::Lorem.word.humanize }
    item_type 'text'
    description 'text'
    required true
    questionnaire_id nil

    trait :with_one_question do
      after(:create) do |item|
        create(:item_option, item_id: item.id)
      end
    end
  end
end
