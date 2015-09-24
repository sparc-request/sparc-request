class AdditionalDetail < ActiveRecord::Base
  audited

  belongs_to :service
  has_many :line_item_additional_details

  attr_accessible :approved, :description, :effective_date, :form_definition_json, :name

  validates :name,:effective_date, :form_definition_json, :presence => true
  validates :description, :length => {:maximum => 255}
  
  before_destroy :line_items_present
  before_update :line_items_present
    
  validate :date_in_past, :effective_date_cannot_be_shared, :form_definition_cannot_be_blank, :no_line_item_additional_detail

  def no_line_item_additional_detail   
    if LineItemAdditionalDetail.where(additional_detail_id: id).size.to_i > 0
      errors.add(:form_definition_json, "Cannot be edited when response has been saved.")
    end
  end
  
  def line_items_present
    if LineItemAdditionalDetail.where(:additional_detail_id => @additional_detail).count > 0
      errors.add(:form_definition_json, "Cannot delete or update additional detail with line item additional details")
    end
    errors.blank?
  end
  
  def date_in_past
    if  !effective_date.blank? and effective_date.beginning_of_day <= Date.yesterday.beginning_of_day
      errors.add(:effective_date, "Date cannot be in past.")
    end
  end

  def form_definition_cannot_be_blank
    blankForm = '{ "schema": { "type": "object","title": "Comment", "properties": {},"required": []}, "form": []}'
    if !form_definition_json.blank? and JSON.parse(form_definition_json) == JSON.parse(blankForm)
        errors.add(:form_definition_json, "Form must contain at least one question.")
    end
  end
 
  def effective_date_cannot_be_shared
    shared_dates = AdditionalDetail.where(effective_date: effective_date,  service_id: service)
    if shared_dates.size > 1 ||  (shared_dates.size == 1 and shared_dates[0].id != id)
        errors.add(:effective_date, "Effective date cannot be the same as any other effective dates.")
    end
  end
  
end
