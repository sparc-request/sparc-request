class ResearchTypesInfo < ActiveRecord::Base
  audited

  self.table_name = 'research_types_info'

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :human_subjects
  attr_accessible :vertebrate_animals
  attr_accessible :investigational_products
  attr_accessible :ip_patents
end
