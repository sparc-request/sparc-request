class AdditionalDetail < ActiveRecord::Base
  audited

  belongs_to :service    
  has_many :line_item_additional_details

  attr_accessible :enabled, :description, :effective_date, :form_definition_json, :name

  before_destroy :line_items_present
  validate :line_items_present
  validates :name,:effective_date, :form_definition_json, :presence => true
  validates :description, :length => {:maximum => 255}
  validate :date_in_past, :effective_date_cannot_be_shared, :form_definition_must_have_at_least_one_required_question
  
  
  def schema_hash
    JSON.parse(self.form_definition_json).fetch('schema')
  end
  
  def form_array
    JSON.parse(self.form_definition_json).fetch('form')
  end
  
  def required_question_keys
    self.schema_hash.fetch('required')
  end
  
  def has_required_questions?
    self.required_question_keys.length > 0
  end
  
  def export_array
    export_array = Array.new
    # sort by??
    self.line_item_additional_details.each do |line_item_additional_detail|
      export_array << line_item_additional_detail.export_hash
    end
    export_array
  end
  
  private
  
  def line_items_present
    if line_item_additional_details.empty?
      true
    else
      errors[:base] << "This Additional Detail cannot be changed if responses exist."
      false
    end
  end

  def date_in_past
    if  !effective_date.blank? && effective_date.beginning_of_day <= Date.yesterday.beginning_of_day
      errors.add(:effective_date, "cannot be in past.")
    end
  end

  def form_definition_must_have_at_least_one_required_question
    if !form_definition_json.blank? && !has_required_questions?
        errors.add(:form_definition_json, "must contain at least one required question.")
    end
  end
 
  def effective_date_cannot_be_shared
    shared_dates = AdditionalDetail.where(effective_date: effective_date,  service_id: service)
    if shared_dates.size > 1 ||  (shared_dates.size == 1 and shared_dates[0].id != id)
        errors.add(:effective_date, "is being used by another version of this form, please choose a different date.")
    end
  end
  
end
