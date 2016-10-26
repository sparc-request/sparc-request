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
  factory :arm do
    name { Faker::Lorem.sentence(3) }
    subject_count 1
    visit_count 1

    transient do
      line_item_count   0
      service_request   nil
    end

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    after(:create) do |arm, evaluator|
      if arm.visit_count.present? && arm.visit_count > 0 && evaluator.line_item_count > 0
        sr = evaluator.service_request || create(:service_request_without_validations)

        vgs = []
        arm.visit_count.times do |n|
          vgs << arm.visit_groups.create(name: "Visit #{n}", position: n + 1, day: n,
                        window_before: nil, window_after: nil)
        end

        evaluator.line_item_count.times do |n|
          li = create(:line_item_with_service, service_request: sr)
          liv = create(:line_items_visit, arm: arm, line_item: li, subject_count: arm.subject_count)
          vgs.each do |vg|
            create(:visit, line_items_visit: liv, visit_group: vg)
          end
        end

        arm.reload
      end
    end

    factory :arm_without_validations, traits: [:without_validations]
  end
end
