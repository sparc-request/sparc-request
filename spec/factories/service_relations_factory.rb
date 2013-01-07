FactoryGirl.define do

  factory :service_relation do
    related_service_id { Random.rand(10000) }
    optional           { false }

    trait :is_optional do
      is_optional true
    end
  end
end
