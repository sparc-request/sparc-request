require 'open-uri'
require 'json'
require 'fileutils'
require 'ostruct'
require 'pstore'
require 'progress_bar'
require 'optparse'
require 'obis-bridge/obis_entity'

require 'active_support/core_ext/object/blank'

require_relative '../validate/validate'
require_relative '../validate/compare'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',   
    :database => 'sparc_development',  
    :username => 'sparc',
    :password => 'sparc',
) 

$obisentity = ObisEntity.new

def is_study(entity, entity_type)
  return entity_type == 'projects' && entity['attributes']['type'] == 'study'
end

def entity_type(entity)
  entity_type = entity['classes'][0].pluralize
  entity_type = 'studies' if is_study(entity, entity_type)
  return entity_type
end

json = File.read('entities.json')
entities = JSON.parse(json)

obisids = [ ]

opts = OptionParser.new
opts.on('-O', '--obisid OBISID') { |id| obisids << id }
opts.parse(ARGV)

entities_by_obisid = { }
entities.each do |entity|
  obisid = entity['identifiers']['OBISID']
  entities_by_obisid[obisid] = entity
end

if not obisids.empty? then
  entities = obisids.map { |id| entities_by_obisid[id] }
end

puts "Validating entities"
bar = ProgressBar.new(entities.count)
entities.each do |entity|
  entity_type = entity_type(entity)
  id = entity['_id'] || entity['id']

  orig = entity

  new_json = $obisentity.get_one(entity_type, id)
  raise RuntimeError, "Could not find #{entity_type} #{id}" if new_json == 'null'
  new = JSON.parse(new_json)

  prepare_entity(orig)
  orig.compare(new)

  bar.increment!
end
puts

puts "Validating relationships"
bar = ProgressBar.new(entities.count)
entities.each do |entity|
  entity_type = entity_type(entity)
  id = entity['_id'] || entity['id']

  json = RestClient.get(
      "http://localhost:4567/obisentity/#{entity_type}/#{id}/relationships/")
  orig = JSON.parse(json)

  new_json = $obisentity.get_rel_for_one(entity_type, id)
  raise RuntimeError, "Could not find #{entity_type} #{id}" if new_json == 'null'
  new = JSON.parse(new_json)

  orig.each { |rel| prepare_relationship(rel) }
  new.each { |rel| rel.delete('relationship_id') }
  sort_relationships!(orig)
  sort_relationships!(new)
  compare_relationship_types(orig, new)
  orig.compare(new)

  bar.increment!
end
puts

