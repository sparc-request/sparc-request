class HumanSubjectsInfo < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  self.table_name = 'human_subjects_info'

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :hr_number
  attr_accessible :pro_number
  attr_accessible :irb_of_record
  attr_accessible :submission_type
  attr_accessible :irb_approval_date
  attr_accessible :irb_expiration_date
end

