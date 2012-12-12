require 'json'
require 'progress_bar'
require 'rest_client'
require 'optparse'
require 'set'
require 'obis-bridge/obis_entity'

require 'active_support/core_ext/string/inflections'

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

def post_rel(entity_type, obisid, rel, posted)
  return if posted.include?(rel['relationship_id'])

  new = rel.dup
  new['override_obisid'] = true
  new['override_created_at'] = true
  new['override_updated_at'] = true

  # RestClient.post(
  #     "http://localhost:4568/obisentity/#{entity_type}/#{obisid}/relationships/",
  #     new.to_json,
  #     :content_type => 'application/json')
  $obisentity.post_one_rel(entity_type, obisid, new)

  posted.add(rel['relationship_id'])
end

# json = RestClient.get('http://localhost:4567/obisentity/entities/')
# json = STDIN.read # TODO: won't work with ProgressBar
json = File.read('entities.json')
entities = JSON.parse(json)

entities_by_obisid = { }
entities.each do |entity|
  obisid = entity['identifiers']['OBISID']
  entities_by_obisid[obisid] = entity
end
obisids = [ ]

opts = OptionParser.new
opts.on('-O', '--obisid OBISID') { |id| obisids << id }
opts.parse(ARGV)

if not obisids.empty? then
  entities = obisids.map { |id| entities_by_obisid[id] }
end

posted = Set.new
bar = ProgressBar.new(entities.count)
entities.each do |entity|
  entity_type = entity_type(entity)
  obisid = entity['identifiers']['OBISID']
  json = RestClient.get(
      "http://localhost:4567/obisentity/#{entity_type}/#{obisid}/relationships/")
  relationships = JSON.parse(json)
  relationships.each do |rel|
    post_rel(entity_type, obisid, rel, posted)
  end
  bar.increment!
end

