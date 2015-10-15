class LineItemAdditionalDetail < ActiveRecord::Base
  audited

  belongs_to :line_item
  belongs_to :additional_detail
  attr_accessible :form_data_json

  validates :form_data_json, presence: true, on: :update
  validate :form_data_json_must_be_parsable, on: :update

  before_create :default_empty_json
  
  def sub_service_request_status
    line_item.sub_service_request.status
  end
  
  def required_fields_present
    if self.additional_detail and self.additional_detail.form_definition_json and self.form_data_json
      required_data = JSON.parse(self.additional_detail.form_definition_json).fetch('schema').fetch('required')
      results = JSON.parse(self.form_data_json)
      for required in required_data do
        if !results.has_key?(required)
          return false
        end
      end
      return true
    end
  end
  
  def form_data_hash
    JSON.parse(self.form_data_json)
  end
  
  def additional_detail_breadcrumb
    self.line_item.additional_detail_breadcrumb
  end
  
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

  # if value use it, otherwise set default
  def default_empty_json
    self.form_data_json ||= '{}'
  end

end
