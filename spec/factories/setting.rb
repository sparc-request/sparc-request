# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  factory :setting do
    sequence(:key) { |n| "setting-#{n}" }
    data_type      { ['boolean', 'string', 'json', 'email', 'url', 'path',].sample }
    value          { nil }
    friendly_name  { Faker::Lorem.word }
    description    { Faker::Lorem.sentence }
    group          { rand(0..10) }
    version        { '1.0' }

    trait :boolean do
      data_type { 'boolean' }
      value     { [true, false].sample }
    end

    trait :json do
      data_type { 'json' }
      value     { '{"key":"value"}' }
    end

    trait :email do
      data_type { 'email' }
      value     { 'sparc@musc.edu' }
    end

    trait :url do
      data_type { 'url' }
      value     { 'https://sparc.musc.edu/dashboard/protocols/' }
    end

    trait :path do
      data_type { 'path' }
      value     { '/dashboard/protocols/?admin=false' }
    end
  end
end
