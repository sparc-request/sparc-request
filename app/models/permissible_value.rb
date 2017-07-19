class PermissibleValue < ApplicationRecord

  # Get the first PermissibleValue value using a category and key
  def self.get_value(category, key)
    PermissibleValue.where(category: category, key: key).first.try(:value)
  end

  # Get an array of PermissibleValue values with the given category
  def self.get_value_list(category)
    PermissibleValue.where(category: category).pluck(:value)
  end

  # Get an array of PermissibleValue keys with the given category
  def self.get_key_list(category)
    PermissibleValue.where(category: category).pluck(:key)
  end

  # Get a hash of PermissibleValue keys as they keys and values as values
  def self.get_hash(category)
    Hash[PermissibleValue.where(category: category).pluck(:key, :value)]
  end

  # Get a hash of PermissibleValue values as the keys and keys as values
  def self.get_inverted_hash(category)
    Hash[PermissibleValue.where(category: category).pluck(:value, :key)]
  end
end
