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

  belongs_to :parent, -> { find_by_key(self.parent_key) }, class_name: 'Setting'

  validates_uniqueness_of :key

  validates :data_type, inclusion: { in: %w(boolean string json email url path) }, presence: true
  validates :parent_key, inclusion: { in: Setting.all.pluck(:key) }, allow_blank: true

  validate :value_matches_type, if: Proc.new{ !self.read_attribute(:value).nil? }
  validate :parent_value_matches_parent_type, if: Proc.new{ self.parent_key.present? }

  def self.safe_value(key)
    s = Setting.find_by_key(key)
    return nil if s.nil?
    s.value
  end

  # Needed to correctly write boolean true and false as value in specs
  def value=(value)
    if [TrueClass, FalseClass].include?(value.class)
      value_will_change!
      write_attribute(:value, value ? "true" : "false")
    else
      write_attribute(:value, value)
    end
  end

  def value
    case data_type
    when 'boolean'
      read_attribute(:value) == 'true'
    when 'json'
      begin
        JSON.parse(read_attribute(:value).gsub("=>", ": "))
      rescue
        nil
      end
    else
      read_attribute(:value)
    end
  end

  private

  def value_matches_type
    errors.add(:value, 'does not match the provided data type') unless
      case data_type
      when 'boolean'
        is_boolean?(read_attribute(:value))
      when 'json'
        is_json?(read_attribute(:value))
      when 'email'
        is_email?(read_attribute(:value))
      when 'url'
        is_url?(read_attribute(:value))
      when 'path'
        is_path?(read_attribute(:value))
      else # Default type = string, no validation needed
        !read_attribute(:value).nil?
      end
  end

  def parent_value_matches_parent_type
    errors.add(:parent_value, 'does not match the parent\'s data type') unless
      case data_type
      when 'boolean'
        is_boolean?(self.parent.read_attribute(:value))
      when 'json'
        is_json?(self.parent.read_attribute(:value))
      when 'email'
        is_email?(self.parent.read_attribute(:value))
      when 'url'
        is_url?(self.parent.read_attribute(:value))
      when 'path'
        is_path?(self.parent.read_attribute(:value))
      else # Default type = string, no validation needed
        !self.parent.read_attribute(:value).nil?
      end
  end
end
