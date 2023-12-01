# Copyright © 2011-2022 MUSC Foundation for Research Development
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

FactoryBot.define do
  factory :irb_record do
    pro_number                { Random.rand(20000).to_s }
    irb_of_record             { Faker::Lorem.word }
    submission_type           { Faker::Lorem.word }
    approval_pending          { false }
    initial_irb_approval_date { Faker::Date.between(from: 1.year.ago, to: Date.today) }
    irb_approval_date         { Faker::Date.between(from: Date.today, to: 1.year.from_now) }
    irb_expiration_date       { Faker::Date.between(from: 1.year.from_now, to: 2.years.from_now) }

    trait :without_validations do
      to_create { |instance| instance.save(validate: false) }
    end

    trait :without_validations_or_callbacks do
      to_create { |instance| 
        IrbRecord.skip_callback(:save, :before, :check_for_rmid_irb)
        instance.save(validate: false)
        IrbRecord.set_callback(:save, :before, :check_for_rmid_irb) 
      }
    end

    factory :irb_record_without_validations, traits: [:without_validations]
    
    factory :irb_record_without_validations_or_callbacks, traits: [:without_validations_or_callbacks]
  end
end
