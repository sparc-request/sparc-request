FactoryGirl.define do

  factory :pricing_map do
    unit_type                  { Faker::Lorem.word }
    unit_factor                { 1 }
    percent_of_fee             { 50 }
    is_one_time_fee            { false }
    full_rate                  { 100 }
    exclude_from_indirect_cost { false }
    unit_minimum               { 1 }
    display_date               Date.parse('2000-01-01')
    effective_date             Date.parse('2000-01-01')

    trait :is_one_time_fee do
      is_one_time_fee true
    end

    trait :exclude_from_indirect_cost do
      excluse_from_indirect_cost true
    end
  end
end
