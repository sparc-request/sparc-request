FactoryGirl.define do

  factory :organization do
    name          { Faker::Lorem.sentence(3) }
    description   { Faker::Lorem.paragraph(4) }
    abbreviation  { Faker::Lorem.word }
    ack_language  { Faker::Lorem.paragraph(4) }
    process_ssrs  { false }
    is_available  { true }

    trait :process_ssrs do
      process_ssrs true
    end

    trait :disabled do
      is_available false
    end

    ignore do
      sub_service_request_count 0
      service_count 0
      catalog_manager_count 0
      super_user_count 0
      service_provider_count 0
      pricing_setup_count 0
      submission_email_count 0
    end

    after(:build) do |organization, evaluator|
      FactoryGirl.create_list(:sub_service_request, evaluator.sub_service_request_count, 
        organization: organization)

      FactoryGirl.create_list(:service, evaluator.service_count,
        organization: organization)

      FactoryGirl.create_list(:catalog_manager,
       evaluator.catalog_manager_count, organization: organization)

      FactoryGirl.create_list(:super_user,
       evaluator.super_user_count, organization: organization)

      FactoryGirl.create_list(:service_provider, evaluator.service_provider_count,
       organization: organization)

      FactoryGirl.create_list(:pricing_setup, evaluator.pricing_setup_count,
       organization: organization)

      FactoryGirl.create_list(:submission_email, evaluator.submission_email_count,
       organization: organization)
    end
    
  end

  factory :institution do
    id            
    name          { Faker::Lorem.sentence(3) }
    description   { Faker::Lorem.paragraph(4) }
    abbreviation  { Faker::Lorem.word }
    ack_language  { Faker::Lorem.paragraph(4) }
    process_ssrs  { false }
    is_available  { true }

    trait :disabled do
      is_available false
    end

    ignore do
      catalog_manager_count 0
      super_user_count 0
    end

    after(:build) do |organization, evaluator|
      FactoryGirl.create_list(:catalog_manager,
       evaluator.catalog_manager_count, organization: organization)

      FactoryGirl.create_list(:super_user,
       evaluator.super_user_count, organization: organization)

    end
  end

  factory :provider do
    id            
    name          { Faker::Lorem.sentence(3) }
    description   { Faker::Lorem.paragraph(4) }
    abbreviation  { Faker::Lorem.word }
    ack_language  { Faker::Lorem.paragraph(4) }
    process_ssrs  { false }
    is_available  { true }

    trait :process_ssrs do
      process_ssrs true
    end

    trait :disabled do
      is_available false
    end

    ignore do
      sub_service_request_count 0
      catalog_manager_count 0
      super_user_count 0
      service_provider_count 0
      pricing_setup_count 0
      submission_email_count 0
    end

    after(:build) do |organization, evaluator|
      FactoryGirl.create_list(:sub_service_request, evaluator.sub_service_request_count, 
        organization: organization)

      FactoryGirl.create_list(:catalog_manager,
       evaluator.catalog_manager_count, organization: organization)

      FactoryGirl.create_list(:super_user,
       evaluator.super_user_count, organization: organization)

      FactoryGirl.create_list(:service_provider, evaluator.service_provider_count,
       organization: organization)

      FactoryGirl.create_list(:pricing_setup, evaluator.pricing_setup_count,
       organization: organization)

      FactoryGirl.create_list(:submission_email, evaluator.submission_email_count,
       organization: organization)
    end

  end

  factory :program do
    id            
    name          { Faker::Lorem.sentence(3) }
    description   { Faker::Lorem.paragraph(4) }
    abbreviation  { Faker::Lorem.word }
    ack_language  { Faker::Lorem.paragraph(4) }
    process_ssrs  { false }
    is_available  { true }

    trait :process_ssrs do
      process_ssrs true
    end

    trait :disabled do
      is_available false
    end
  
    ignore do
      sub_service_request_count 0
      service_count 0
      catalog_manager_count 0
      super_user_count 0
      service_provider_count 0
      pricing_setup_count 0
      submission_email_count 0
    end

    after(:build) do |organization, evaluator|
      FactoryGirl.create_list(:sub_service_request, evaluator.sub_service_request_count, 
        organization: organization)

      FactoryGirl.create_list(:service, evaluator.service_count,
        organization: organization)

      FactoryGirl.create_list(:catalog_manager,
       evaluator.catalog_manager_count, organization: organization)

      FactoryGirl.create_list(:super_user,
       evaluator.super_user_count, organization: organization)

      FactoryGirl.create_list(:service_provider, evaluator.service_provider_count,
       organization: organization)

      FactoryGirl.create_list(:pricing_setup, evaluator.pricing_setup_count,
       organization: organization)

      FactoryGirl.create_list(:submission_email, evaluator.submission_email_count,
       organization: organization)
    end

  end

  factory :core do
    id            
    name          { Faker::Lorem.sentence(3) }
    description   { Faker::Lorem.paragraph(4) }
    abbreviation  { Faker::Lorem.word }
    ack_language  { Faker::Lorem.paragraph(4) }
    process_ssrs  { false }
    is_available  { true }

    trait :process_ssrs do
      process_ssrs true
    end

    trait :disabled do
      is_available false
    end
  
    ignore do
      sub_service_request_count 0
      service_count 0
      catalog_manager_count 0
      super_user_count 0
      service_provider_count 0
      submission_email_count 0
    end

    after(:build) do |organization, evaluator|
      FactoryGirl.create_list(:sub_service_request, evaluator.sub_service_request_count, 
        organization: organization)

      FactoryGirl.create_list(:service, evaluator.service_count,
        organization: organization)

      FactoryGirl.create_list(:catalog_manager,
       evaluator.catalog_manager_count, organization: organization)

      FactoryGirl.create_list(:super_user,
       evaluator.super_user_count, organization: organization)

      FactoryGirl.create_list(:service_provider, evaluator.service_provider_count,
       organization: organization)

      FactoryGirl.create_list(:submission_email, evaluator.submission_email_count,
       organization: organization)
    end

  end

end
