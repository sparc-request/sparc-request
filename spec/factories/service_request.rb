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
  factory :service_request do
    protocol_id          { Random.rand(10000) }
    status               { Faker::Lorem.sentence(3) }
    approved             { false }

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :with_protocol do
      protocol factory: :protocol_federally_funded
    end

    trait :approved do
      approved true
    end

    transient do
      sub_service_count 0
      line_item_count 0
      subsidy_count 0
      charge_count 0
      token_count 0
      approval_count 0
      organizations []
    end

    after(:build) do |service_request, evaluator|
      create_list(:sub_service_request, evaluator.sub_service_count,
        service_request: service_request)

      create_list(:line_item, evaluator.line_item_count,
        service_request: service_request)

      create_list(:subsidy, evaluator.subsidy_count,
        service_request: service_request)

      create_list(:charge, evaluator.charge_count,
        service_request: service_request)

      create_list(:token, evaluator.token_count,
        service_request: service_request)

      create_list(:approval, evaluator.approval_count,
        service_request: service_request)
    end

    after(:create) do |service_request, evaluator|
      evaluator.organizations.each do |org|
        service_request.sub_service_requests << create(:sub_service_request, organization: org)
      end
    end

    factory :service_request_without_validations, traits: [:without_validations]
    factory :service_request_with_protocol, traits: [:with_protocol]
  end
end
