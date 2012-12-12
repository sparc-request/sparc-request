class Affiliation < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :name
  attr_accessible :new
  attr_accessible :position
  attr_accessor :new
  attr_accessor :position

  TYPES = {
    'cancer_center' => 'Cancer Center',
    'lipidomics_cobre' => 'Lipidomics COBRE',
    'oral_health_cobre' => 'Oral Health COBRE',
    'cardiovascular_cobre' => 'Cardiovascular COBRE',
    'cchp' => 'CCHP',
    'inbre' => 'INBRE',
    'reach' => 'REACH'
  }
end

