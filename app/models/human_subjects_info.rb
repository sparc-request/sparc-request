class HumanSubjectsInfo < ActiveRecord::Base
  audited

  self.table_name = 'human_subjects_info'

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :nct_number
  attr_accessible :hr_number
  attr_accessible :pro_number
  attr_accessible :irb_of_record
  attr_accessible :submission_type
  attr_accessible :irb_approval_date
  attr_accessible :irb_expiration_date
  attr_accessible :approval_pending

  def irb_and_pro_numbers
    string = ""
    string += "HR # #{self.hr_number} " unless hr_number.blank?
    string += "PRO # #{self.pro_number} " unless pro_number.blank?
  end
end

