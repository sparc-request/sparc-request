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
  factory :line_item do
    optional               { false }
    quantity               { 5 }

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :with_service_request do
      service_request
      # service_request factory: :service_request_with_protocol
    end

    trait :with_service do
      service factory: :service_with_process_ssrs_organization
    end

    trait :is_optional do
      optional true
    end

    trait :per_patient_per_visit do
      service factory: :per_patient_per_visit_service
    end

    trait :one_time_fee do
      service factory: :one_time_fee_service
    end

    transient do
      fulfillment_count 0
      visit_count 0
    end

    after(:build) do |line_item, evaluator|
      create_list(:fulfillment, evaluator.fulfillment_count,
        line_item: line_item)

      create_list(:visit, evaluator.visit_count,
        line_item: line_item)
    end

    factory :line_item_with_service, traits: [:with_service, :with_service_request]
    factory :one_time_fee_line_item, traits: [:one_time_fee]
    factory :per_patient_per_visit_line_item, traits: [:per_patient_per_visit]
    factory :line_item_without_validations, traits: [:without_validations]
  end
end
