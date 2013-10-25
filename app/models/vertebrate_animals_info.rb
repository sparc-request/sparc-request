class VertebrateAnimalsInfo < ActiveRecord::Base
  audited

  self.table_name = 'vertebrate_animals_info'

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :iacuc_number
  attr_accessible :name_of_iacuc
  attr_accessible :iacuc_approval_date
  attr_accessible :iacuc_expiration_date
end
