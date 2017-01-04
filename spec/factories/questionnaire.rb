FactoryGirl.define do
  factory :questionnaire do
    name 'string'
    service_id nil
    active 1

    trait :with_all_question_types do
      after(:create) do |questionnaire|
        ADDITIONAL_DETAIL_QUESTION_TYPES.values.each do |qt|
          questionnaire.items << create( :item, item_type: qt )
        end
      end
    end
  end
end
