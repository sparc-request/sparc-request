class IpPatentsInfo < ActiveRecord::Base
  audited
  self.table_name = 'ip_patents_info'

  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :patent_number
  attr_accessible :inventors
end

