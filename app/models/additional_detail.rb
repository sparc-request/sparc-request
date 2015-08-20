class AdditionalDetail < ActiveRecord::Base
  audited

  belongs_to :service
  has_many :line_item_additional_details

  attr_accessible :approved, :description, :effective_date, :form_definition_json, :name

  validates :name,:effective_date, :form_definition_json, :presence => true
  #validates :description, :length => {:maximum => 255}
  validates :effective_date, :uniqueness => { message: "Effective date cannot be the same as any other effective dates." }
  validates :form_definition_json, :exclusion => { :in=> ['{"schema": {"type": "object","title": "Comment","properties": {},"required": []},"form": []}'],
    :message => "Form must contain at least one question." }

  validate :date_in_past

  def date_in_past
    if  !effective_date.blank? and effective_date < Date.yesterday
      errors.add(:effective_date, "Date must be in past.")
    end
  end

end
