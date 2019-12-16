# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class PermissibleValue < ApplicationRecord
  belongs_to :parent, class_name: 'PermissibleValue'

  acts_as_list column: :sort_order, scope: [:category]

  validates :key, uniqueness: { scope: :category }

  default_scope { order(:sort_order) }

  scope :available, -> {
    where(is_available: true)
  }

  scope :unavailable, -> {
    where(is_available: false)
  }

  def self.preload_values
    RequestStore.store[:permissible_values] ||= PermissibleValue.all.group_by(&:category).map{ |category, values| [category, values.map{ |p| [p.key, { value: p.value, default: p.default }] }.to_h] }.to_h
  end

  # Get the first PermissibleValue value using a category and key
  def self.get_value(category, key)
    if value = RequestStore.store[:permissible_values].try(:[], category).try(:[], key).try(:[], :value)
      value
    else
      PermissibleValue.where(category: category, key: key).first.try(:value)
    end
  end

  # Get an array of PermissibleValue keys with the given category
  def self.get_key_list(category, default=nil)
    if default.nil?
      if values = RequestStore.store[:permissible_values].try(:[], category)
        values.keys
      else
        PermissibleValue.available.where(category: category).pluck(:key)
      end
    else
      if values = RequestStore.store[:permissible_values].try(:[], category)
        values.select{ |key, data| data[:default] == default }.keys
      else
        PermissibleValue.available.where(category: category, default: default).pluck(:key)
      end
    end
  end

  # Get a hash of PermissibleValue keys as the keys and values as the values
  def self.get_hash(category, default=nil)
    if default.nil?
      if values = RequestStore.store[:permissible_values].try(:[], category)
        values.map{ |key, data| [key, data[:value]] }.to_h
      else
        Hash[PermissibleValue.available.where(category: category).pluck(:key, :value)]
      end
    else
      if values = RequestStore.store[:permissible_values].try(:[], category)
        values.select{ |key, data| data[:default] == default }.map{ |key, data| [key, data[:value]] }.to_h
      else
        Hash[PermissibleValue.available.where(category: category, default: default).pluck(:key, :value)]
      end
    end
  end

  # Get a hash of PermissibleValue values as the keys and keys as the values
  def self.get_inverted_hash(category, default=nil)
    if default.nil?
      if values = RequestStore.store[:permissible_values].try(:[], category)
        values.map{ |key, data| [data[:value], key] }.to_h
      else
        Hash[PermissibleValue.available.where(category: category).pluck(:value, :key)]
      end
    else
      if values = RequestStore.store[:permissible_values].try(:[], category)
        values.select{ |key, data| data[:default] == default }.map{ |key, data| [data[:value], key] }.to_h
      else
        Hash[PermissibleValue.available.where(category: category, default: default).pluck(:value, :key)]
      end
    end
  end
end
