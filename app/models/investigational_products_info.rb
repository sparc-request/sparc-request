class InvestigationalProductsInfo < ActiveRecord::Base
  self.table_name = 'investigational_products_info'

  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :ind_number
  attr_accessible :ide_number
  attr_accessible :ind_on_hold
end

