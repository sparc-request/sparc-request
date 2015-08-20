class AdditionalDetail < ActiveRecord::Base
  audited
  
  belongs_to :service
  has_many :line_item_additional_details
  
  attr_accessible :approved, :description, :effective_date, :form_definition_json, :name
  
  validates :name, :presence => true
end
