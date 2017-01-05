FactoryGirl.define do
  factory :questionnaire do
    name {Faker::Lorem.word.humanize}
    service_id nil
    active 1

    trait :with_all_question_types do
      after(:create) do |questionnaire|
        ADDITIONAL_DETAIL_QUESTION_TYPES.values.each do |qt|
          questionnaire.items << create( :item, item_type: qt )
        end
      end
    end

    trait :with_responses do
      after(:create) do |questionnaire|
        (1..rand(10)).each do
          questionnaire.submissions << build(:submission)
        end
      end
    end

    factory :questionnaire_with_responses, traits: [:with_responses]
  end
end
