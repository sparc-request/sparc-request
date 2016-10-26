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
  factory :sub_service_request do
    service_requester_id { Random.rand(1000) }

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end
    
    trait :with_payment do
      after(:create) do |sub_service_request, evaluator|
        FactoryGirl.create(:payment, sub_service_request: sub_service_request)
      end
    end

    transient do
      line_item_count 0
      past_status_count 0
    end

    after(:build) do |sub_service_request, evaluator|
      create_list(:line_item, evaluator.line_item_count,
        sub_service_request: sub_service_request)

      create_list(:past_status, evaluator.past_status_count,
        sub_service_request: sub_service_request)
    end

    trait :in_cwf do
      in_work_fulfillment true
    end

    trait :with_subsidy do
      after(:create) do |sub_service_request, evaluator|
        create(:subsidy_without_validations, sub_service_request: sub_service_request)
      end
    end

    trait :with_organization do
      organization
    end

    factory :sub_service_request_with_organization, traits: [:with_organization]
    factory :sub_service_request_with_payment, traits: [:with_payment]
    factory :sub_service_request_in_cwf, traits: [:in_cwf]
    factory :sub_service_request_with_subsidy, traits: [:with_subsidy]
    factory :sub_service_request_without_validations, traits: [:without_validations]
  end
end
