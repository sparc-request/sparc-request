class VertebrateAnimalsInfo < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  self.table_name = 'vertebrate_animals_info'

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :iacuc_number
  attr_accessible :name_of_iacuc
  attr_accessible :iacuc_approval_date
  attr_accessible :iacuc_expiration_date
end
