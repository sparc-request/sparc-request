FactoryGirl.define do
  factory :subsidy_map do
    ignore do
      excluded_funding_source_count 0
    end

    after(:build) do |subsidy_map, evaluator|
      FactoryGirl.create_list(:excluded_funding_source,
       evaluator.excluded_funding_source_count, subsidy_map: subsidy_map)
    end
  end
end
