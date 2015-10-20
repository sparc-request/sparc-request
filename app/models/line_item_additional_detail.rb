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
  
  def service_requester_name
    self.try(:line_item).try(:sub_service_request).try(:service_request).try(:service_requester).try(:display_name)
  end
  
  def protocol_short_title
    self.try(:line_item).try(:sub_service_request).try(:service_request).try(:protocol).try(:short_title)
  end  

  def has_answered_all_required_questions?
    if self.additional_detail and self.additional_detail.has_required_questions? and self.form_data_json
      user_answers = JSON.parse(self.form_data_json)
      self.additional_detail.required_question_keys.each do |required_question_key|
        if !user_answers.has_key?(required_question_key)
          return false
        end
      end
    end
    true
  end
  
  def form_data_hash
    JSON.parse(self.form_data_json)
  end
  
  def additional_detail_schema_hash
    if self.additional_detail
      self.additional_detail.schema_hash
    else
      {}
    end
  end
  
  def additional_detail_form_array
    if self.additional_detail
      self.additional_detail.form_array
    else
      []
    end
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