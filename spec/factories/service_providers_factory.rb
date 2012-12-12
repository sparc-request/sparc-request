FactoryGirl.define do

  factory :service_provider do
    id                 
    is_primary_contact { false }

    trait :is_primary_contact do
      is_primary_contact true
    end
  end
end