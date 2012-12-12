FactoryGirl.define do
  
  factory :identity do
    id                    { Random.rand(10000) }
    obisid                { SecureRandom.hex(16) }
    ldap_uid              { Faker::Internet.user_name }
    last_name             { Faker::Name.last_name }
    first_name            { Faker::Name.first_name }
    email                 { Faker::Internet.email }
    institution           { Faker::Company.name }
    college               { Faker::Company.name }
    department            { Faker::Company.name }
    era_commons_name      { Faker::Internet.user_name }
    credentials           { Faker::Name.suffix }
    subspecialty          { Faker::Lorem.word }
    phone                 { Faker::PhoneNumber.phone_number }
    password              "abc123456789!"
    password_confirmation "abc123456789!"


    created_at       { 1.day.ago }
    updated_at       { Time.now }

    ignore do
      catalog_manager_count 0
      super_user_count 0
      approval_count 0
      project_role_count 0
      service_provider_count 0
    end

      after(:build) do |identity, evaluator|
        FactoryGirl.create_list(:catalog_manager,
         evaluator.catalog_manager_count, identity: identity)
    
        FactoryGirl.create_list(:super_user,
         evaluator.super_user_count, identity: identity)
    
        FactoryGirl.create_list(:approval,
         evaluator.approval_count, identity: identity)
    
        FactoryGirl.create_list(:project_role,
         evaluator.project_role_count, identity: identity)
    
        FactoryGirl.create_list(:service_provider,
         evaluator.service_provider_count, identity: identity)
    end
  end
end
