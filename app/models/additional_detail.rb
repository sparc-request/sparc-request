class AdditionalDetail < ActiveRecord::Base
  audited

  belongs_to :service
  has_many :line_item_additional_details

  attr_accessible :approved, :description, :effective_date, :form_definition_json, :name

  validates :name,:effective_date, :form_definition_json, :presence => true
  validates :description, :length => {:maximum => 255}
  
  validate :date_in_past, :effective_date_cannot_be_shared, :form_definition_cannot_be_blank, :no_line_item_additional_detail

  def no_line_item_additional_detail
    unless LineItemAdditionalDetail.where(additional_detail_id: id).size == 0
      errors.add(:form_definition_json, "Form must contain at least one question.")
    end
  end
  
  def date_in_past
    if  !effective_date.blank? and effective_date.beginning_of_day <= Date.yesterday.beginning_of_day
      errors.add(:effective_date, "Date must be in past.")
    end
  end

  def form_definition_cannot_be_blank
    invaildList = ['{"schema":{"type":"object","title":"Comment","properties":{},"required":[]},"form":[]}']
    if !form_definition_json.blank? and invaildList.include?(form_definition_json.gsub!(/\s+/, ""))
      errors.add(:form_definition_json, "Form must contain at least one question.")
    end
  end
 
  def effective_date_cannot_be_shared
    unless AdditionalDetail.where(effective_date: effective_date,  service_id: service).size == 0
      errors.add(:effective_date, "Effective date cannot be the same as any other effective dates.")
    end
  end
  
end
