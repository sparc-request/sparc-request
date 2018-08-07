class ShortInteraction < ApplicationRecord
  audited

  belongs_to :identity

  validates :subject,
            :interaction_type,
            :duration_in_minutes,
            :name,
            :email,
            :institution,
            :note,
            presence: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_numericality_of :duration_in_minutes


  def display_subject
    subject.nil? ? "" : "#{PermissibleValue.get_value('interaction_subject', subject)}"
  end


  def display_interaction_type
    interaction_type.nil? ? "" : "#{PermissibleValue.get_value('interaction_type', interaction_type)}"
  end

end
