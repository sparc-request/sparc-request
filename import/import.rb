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

$obisentity = ObisEntity.new

def is_study(entity, entity_type)
  return entity_type == 'projects' && entity['attributes']['type'] == 'study'
end

def entity_type(entity)
  entity_type = entity['classes'][0].pluralize
  entity_type = 'studies' if is_study(entity, entity_type)
  return entity_type
end

def dependencies(entity)
  dependencies = [ ]

  attributes = entity['attributes']

  if attributes['service_requester_id'] then
    dependencies << attributes['service_requester_id']
  end

  if attributes['line_items'] then
    attributes['line_items'].each do |line_item|
      dependencies << line_item['service_id']
    end
  end

  if attributes['sub_service_requests'] then
    attributes['sub_service_requests'].each do |ssr_id, ssr|
      organization_id = ssr['core_id'] || ssr['program_id'] || ssr['provider_id'] || ssr['institution_id']
      dependencies << organization_id
    end
  end

  if attributes['subsidies'] then
    attributes['subsidies'].each do |organization_id, subsidy|
      dependencies << organization_id
    end
  end

  approval_data = attributes['approval_data']

  if approval_data and approval_data[0] and approval_data[0]['charges'] then
    approval_data[0]['charges'].each do |service_id, charge|
      dependencies << service_id
    end
  end

  if approval_data and approval_data[0] and approval_data[0]['approvals'] then
    approval_data[0]['approvals'].each do |identity_id, approval_date|
      dependencies << identity_id
    end
  end

  if approval_data and approval_data[0] and approval_data[0]['tokens'] then
    approval_data[0]['tokens'].each do |token, identity_id|
      dependencies << identity_id
    end
  end

  return dependencies
end

def related(entity)
  related = [ ]

  entity_type = entity_type(entity)
  obisid = entity['identifiers']['OBISID']
  json = RestClient.get(
      "http://localhost:4567/obisentity/#{entity_type}/#{obisid}/relationships/")
  relationships = JSON.parse(json)

  relationships.each do |rel|
    related << rel['from']
    related << rel['to']
  end

  return related
end

def post(entities_by_obisid, entity, posted, posting, post_related=true)
  raise "nil entity" if not entity
  identifiers = entity['identifiers']
  raise "Could not find identifiers in #{entity.inspect}" if not identifiers
  id = identifiers['OBISID']

  return if posting.include?(id)

  posting << id

  dependencies(entity).each do |dep_id|
    dep = entities_by_obisid[dep_id]
    raise "Could not find entity with id #{dep_id} needed by #{id}" if not dep
    post(entities_by_obisid, dep, posted, posting)
  end

  return if posted.include?(id)

  entity_type = entity_type(entity)

  new = entity.dup
  new['override_obisid'] = true
  new['override_created_at'] = true
  new['override_updated_at'] = true

  # RestClient.post(
  #     "http://localhost:4568/obisentity/#{entity_type}/",
  #     new.to_json,
  #     :content_type => 'application/json')
  annotate("posting #{entity.pretty_inspect}") do
    $obisentity.post_one(entity_type, new)
  end

  posting.delete(id)
  posted << id

  if post_related then
    related(entity).each do |related_id|
      related = entities_by_obisid[related_id]
      raise RuntimeError, "Could not find entity with id #{related_id} related to #{id}" if not related
      post(entities_by_obisid, related, posted, posting, false)
    end
  end
end

class Notifier
  # Stub out this method so we don't actually send out any emails
  def self.new_identity_waiting_for_approval(identity)
    return MockEmail.new
  end

  class MockEmail
    def deliver
    end
  end
end

class Import
  def initialize(argv)
    # json = RestClient.get('http://localhost:4567/obisentity/entities/')
    # json = STDIN.read # TODO: won't work with ProgressBar
    json = File.read('entities.json')
    @entities = JSON.parse(json)

    @entities_by_obisid = { }
    @entities.each do |entity|
      obisid = entity['identifiers']['OBISID']
      @entities_by_obisid[obisid] = entity
    end

    @posting = [ ]
    @posted = [ ]

    @obisids = [ ]
    @post_related = true
    @number_of_records = nil
    @disable_validations = false
    @import = [ ]

    opts = OptionParser.new
    opts.on('-O', '--obisid OBISID') { |id| @obisids << id }
    opts.on('-N', '--no-relationships') { @post_related = false }
    opts.on('-n', '--number-of-records N', Integer) { |n| @number_of_records = n }
    opts.on('-X', '--without-validations') { @disable_validations = true }
    opts.on('--import-identities') { @import << :identities }
    opts.on('--import-others') { @import << :others }
    opts.parse(argv)

    @import = [ :identities, :others ] if @import.size == 0

    if not @obisids.empty? then
      @entities = @obisids.map { |id| @entities_by_obisid[id] }
    end

    # Take a count before we remove any entities that we aren't going to
    # import, so the loop will know when to stop
    @number_of_records ||= @entities.count

    @entities.delete_if do |e|
      type = e['classes'][0]
      delete = false
      if type == 'identity' and not @import.include?(:identities) then
        delete = true
        @posted << e['_id']
      end
      if type != 'identity' and not @import.include?(:others) then
        delete = true
        @posted << e['_id']
      end
      delete
    end
  end

  def import
    if @disable_validations then
      ActiveRecord::Base.disable_validation!
    end

    bar = ProgressBar.new(@entities.count)

    # Import identities first
    identities = @entities.select { |e| e['classes'][0] == 'identity' }
    other_entities = @entities - identities

    catch :done do
      ActiveRecord::Base.connection.cache do
        import_entities(bar, identities)
        import_entities(bar, other_entities)
      end
    end
  end

  def import_entities(bar, entities)
    entities.each do |entity|
      post(@entities_by_obisid, entity, @posted, @posting, @post_related)
      bar.increment!
      throw :done if @posted.size >= @number_of_records
    end
  end

end

import = Import.new(ARGV)
import.import

puts

