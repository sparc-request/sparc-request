class LineItemAdditionalDetail < ActiveRecord::Base
  audited
  
  belongs_to :line_item
  belongs_to :additional_detail
  attr_accessible :form_data_json
  
  validates :form_data_json, presence: true, on: :update
  validate :form_data_json_must_be_parsable, on: :update
  
  private
   
  def form_data_json_must_be_parsable
    unless self.form_data_json.blank?
      begin
        JSON.parse(self.form_data_json)
        return true  
      rescue JSON::ParserError  
        errors.add(:form_data_json, "must be valid JSON") 
      end
    end
  end
  
end
