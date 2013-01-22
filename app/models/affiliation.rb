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

  begin
    constant_file = File.join(Rails.root, 'config', 'constants.yml')
    config = YAML::load_file(constant_file)
    TYPES = config['affiliations']
  rescue
    raise "constants.yml not found"
  end
end

