FactoryBot.define do
  factory :external_organization do
    collaborating_org_name { Faker::Lorem.word }
    collaborating_org_type { Faker::Lorem.word }
    collaborating_org_name_other { Faker::Lorem.word }
    collaborating_org_type_other { Faker::Lorem.word }
    comments { Faker::Lorem.sentence(word_count: 5) }

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    factory :external_organization_without_validations, traits: [:without_validations]
  end
end
