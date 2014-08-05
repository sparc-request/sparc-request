# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
