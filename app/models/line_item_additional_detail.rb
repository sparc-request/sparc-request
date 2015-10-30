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
  
  def sub_service_request_id
    line_item.sub_service_request_id
  end
  
  def service_requester_name
    self.line_item.service_requester_name
  end
  
  def protocol_short_title
    self.line_item.protocol_short_title
  end  

  def pi_name
    self.line_item.pi_name
  end
  
  def has_answered_all_required_questions?
    if self.additional_detail && self.additional_detail.has_required_questions? && self.form_data_json
      user_answers = self.form_data_hash
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
  
  def additional_detail_description
    self.additional_detail.description unless self.additional_detail.blank?
  end
  
  # form_data_json hash keys are not allowed to have dashes so include dashes in 
  #   these hash keys to prevent naming conflicts. also, AngularJS UI-Grid separates 
  #   capital letters with spaces so camel case is recommended for hash keys.
  def export_hash
    export_hash = Hash.new
    export_hash["Additional-Detail"] = self.additional_detail_breadcrumb
    export_hash["Effective-Date"] = self.additional_detail.effective_date
    export_hash["Ssr-Id"] = self.sub_service_request_id
    export_hash["Ssr-Status"] = self.sub_service_request_status
    export_hash["Requester-Name"] = self.service_requester_name
    export_hash["Pi-Name"] = self.pi_name
    export_hash["Protocol-Short-Title"] = self.protocol_short_title
    export_hash["Required-Questions-Answered"] = self.has_answered_all_required_questions?
    export_hash["Last-Updated-At"] = self.updated_at ? self.updated_at.strftime("%Y-%m-%d") : ""
    # loop over each field in the additional detail form schema 
    #   and attempt to find its value in the line item additional detail form data
    user_answers = self.form_data_hash
    self.additional_detail_form_array.each do |question|
      # if value not found, insert an empty string so that all rows of responses will have the same # of columns/questions 
      export_hash[question["key"]] = user_answers.has_key?(question["key"]) ? user_answers[question["key"]] : ""
    end
    export_hash
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