class AdditionalDetail < ActiveRecord::Base
  belongs_to :service
  attr_accessible :approved, :description, :effective_date, :form_definition_json, :name
end
