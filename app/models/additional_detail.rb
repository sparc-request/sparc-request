class AdditionalDetail < ActiveRecord::Base
  audited

  belongs_to :service
  has_many :line_item_additional_details

  attr_accessible :approved, :description, :effective_date, :form_definition_json, :name

  validates :name,:effective_date, :form_definition_json, :presence => true
  validates :description, :length => {:maximum => 255}
  validates :form_definition_json, :exclusion => { :in=> ['{"schema": {"type": "object","title": "Comment","properties": {},"required": []},"form": []}'],
    :message => "Form must contain at least one question." }

  validate :date_in_past, :effective_date_cannot_be_shared

  def date_in_past
    if  !effective_date.blank? and effective_date < Date.yesterday
      errors.add(:effective_date, "Date must be in past.")
    end
  end

  def form_definition_cannot_be_blank
    blankForm = '{"schema":{"type":"object","title":"Comment","properties":{},"required":[]},"form":[]}'
    if !form_definition_json.blank? and form_definition_json.gsub!(/\s+/, "") != blankForm
      errors.add(:form_definition_json, "Form cannot be blank.")
    end
    
  end
 
  def effective_date_cannot_be_shared
    unless AdditionalDetail.where(effective_date: effective_date,  service_id: service).size == 0
      errors.add(:effective_date, "Effective date cannot be the same as any other effective dates.")
    end
    
  end
  
end
