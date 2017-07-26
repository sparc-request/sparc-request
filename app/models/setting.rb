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

class Setting < ApplicationRecord
  include DataTypeValidator

  audited

  validates_uniqueness_of :key

  validates :data_type, inclusion: { in: %w(boolean string json email url path) }, presence: true

  validate :value_matches_type, if: Proc.new{ self.value.present? }

  def value
    case data_type
    when 'boolean'
      read_attribute(:value) == 'true'
    when 'json'
      JSON.parse(read_attribute(:value).gsub("=>", ": "))
    else
      read_attribute(:value)
    end
  end

  private

  def value_matches_type
    errors.add(:value, 'invalid type') unless
      case data_type
      when 'boolean'
        is_boolean?(value)
      when 'json'
        is_json?(value)
      when 'email'
        is_email?(value)
      when 'url'
        is_url?(value)
      when 'path'
        is_path?(value)
      else # Default type = string, no validation needed
        true
      end
  end
end
