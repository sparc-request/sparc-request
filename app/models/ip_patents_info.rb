class IpPatentsInfo < ActiveRecord::Base
  self.table_name = 'ip_patents_info'

  audited

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :patent_number
  attr_accessible :inventors
end

