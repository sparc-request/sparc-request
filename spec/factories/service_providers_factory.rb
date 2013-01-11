FactoryGirl.define do

  factory :service_provider do
    is_primary_contact { false }

    trait :is_primary_contact do
      is_primary_contact true
    end
  end
end
