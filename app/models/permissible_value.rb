class PermissibleValue < ApplicationRecord

  # Get the first PermissibleValue value using a category and key
  def self.get_value(category, key)
    PermissibleValue.where(category: category, key: key).first.try(:value)
  end

  # Get an array of PermissibleValue values with the given category
  def self.get_value_list(category)
    PermissibleValue.where(category: category).pluck(:value)
  end
end
