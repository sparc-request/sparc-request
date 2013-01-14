require 'json'
require 'progress_bar'
require 'rest_client'
require 'optparse'
require 'pp'
require 'import'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',   
    :database => 'sparc_development',  
    :username => 'sparc',
    :password => 'sparc',
) 

def is_study(entity, entity_type)
  return entity_type == 'projects' && entity['attributes']['type'] == 'study'
end

def entity_type(entity)
  entity_type = entity['classes'][0].pluralize
  entity_type = 'studies' if is_study(entity, entity_type)
  return entity_type
end

pricing_setups = JSON.parse(File.read('pricing_setups.json'))
pricing_maps = JSON.parse(File.read('pricing_maps.json'))

ActiveRecord::Base.transaction do
  pricing_setups.each do |entity|
    obj = PricingSetup.create_from_json(entity, :jsontype => :pricing)
  end
end

ActiveRecord::Base.transaction do
  pricing_maps.each do |entity|
    obj = PricingMap.create_from_json(entity, :jsontype => :pricing)
  end
end

