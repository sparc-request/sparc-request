class Race < ApplicationRecord

  belongs_to :identity

  attr_accessor :new
  attr_accessor :position

  #### TODO ####
  def display_name
    race = PermissibleValue.get_value('race', self.name)
    if self.name == "other" &&  other_text.present?
      race += " (#{self.other_text})"
    end
    return race
  end
end

