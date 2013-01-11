FactoryGirl.define do
  factory :line_item do
    ssr_id                 { Faker::Lorem.word }
    optional               { false }
    quantity               { 5 }
    subject_count          { 5 }

    trait :is_optional do
      optional true
    end

    ignore do
      fulfillment_count 0
      visit_count 0
    end

    after(:build) do |line_item, evaluator|
      FactoryGirl.create_list(:fulfillment, evaluator.fulfillment_count, 
        line_item: line_item)
    
      FactoryGirl.create_list(:visit, evaluator.visit_count, 
        line_item: line_item)
    end
  end
end
