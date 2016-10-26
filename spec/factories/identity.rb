# Copyright © 2011-2016 MUSC Foundation for Research Development
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
  sequence :ldap_uid do |n|
    "ldap_uid#{n}@email.com"
  end
  
  sequence :email do |n|
    "email#{n}@email.com"
  end

  factory :identity do
    ldap_uid
    last_name             { Faker::Name.last_name }
    first_name            { Faker::Name.first_name }
    email
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

    transient do
      catalog_manager_count 0
      super_user_count 0
      approval_count 0
      project_role_count 0
      service_provider_count 0
    end

    after(:build) do |identity, evaluator|
      create_list(:catalog_manager,
       evaluator.catalog_manager_count, identity: identity)

      create_list(:super_user,
       evaluator.super_user_count, identity: identity)

      create_list(:approval,
       evaluator.approval_count, identity: identity)

      create_list(:project_role,
       evaluator.project_role_count, identity: identity)

      create_list(:service_provider,
       evaluator.service_provider_count, identity: identity)
    end
  end
end
