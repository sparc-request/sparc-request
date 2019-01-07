# Copyright © 2011-2018 MUSC Foundation for Research Development
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
  validates :parent_key, inclusion: { in: Setting.all.pluck(:key) }, allow_blank: true

  validate :value_matches_type, if: Proc.new{ !self.read_attribute(:value).nil? }
  validate :parent_value_matches_parent_data_type, if: Proc.new{ self.parent_key.present? }

  def self.preload_values
    # Cache settings for the current request thread for the current request
    RequestStore.store[:settings_map] ||= Setting.all.map{ |s| [s.key, { value: s.read_attribute(:value), data_type: s.data_type }] }.to_h
  end

  def self.get_value(key)
    if RequestStore.store[:settings_map] && RequestStore.store[:settings_map][key]
      converted_value(RequestStore.store[:settings_map][key][:value], RequestStore.store[:settings_map][key][:data_type])
    else
      Setting.find_by_key(key).value rescue nil
    end
  end

  def value=(val)
    RequestStore.store[:settings_map][key][:value] = val.to_s if RequestStore.store[:settings_map] && RequestStore.store[:settings_map][key]
    
    # Needed to correctly write boolean true and false as value in specs
    if [TrueClass, FalseClass].include?(val.class)
      value_will_change!
      write_attribute(:value, val ? "true" : "false")
    elsif data_type == 'json' && val.is_a?(Hash)
      write_attribute(:value, val.to_json)
    else
      write_attribute(:value, val)
    end
  end

  def value
    Setting.converted_value(read_attribute(:value), self.data_type)
  end

  def parent
    Setting.find_by_key(parent_key) unless parent_key.blank?
  end

  def children
    Setting.where(parent_key: key)
  end

  private

  def self.converted_value(val, data_type)
    case data_type
    when 'boolean'
      val == 'true'
    when 'json'
      begin
        JSON.parse(val.gsub("=>", ": "))
      rescue
        nil
      end
    else
      val
    end
  end

  def value_matches_type
    errors.add(:value, 'does not match the provided data type') unless
      data_type == get_type(read_attribute(:value))
  end

  def parent_value_matches_parent_data_type
    errors.add(:parent_value, 'does not match the parent\'s data type') unless
      parent.data_type == get_type(read_attribute(:parent_value))
  end
end
