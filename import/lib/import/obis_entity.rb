require 'models/identity'
require 'models/core'
require 'models/institution'
require 'models/program'
require 'models/project'
require 'models/provider'
require 'models/service'
require 'models/study'
require 'models/service_request'

require 'active_support/core_ext/string/inflections'

EntityClasses = {
  'cores'                 => Core,
  'identities'            => Identity,
  'programs'              => Program,
  'projects'              => Project,
  'studies'               => Study,
  'providers'             => Provider,
  'services'              => Service,
  'service_requests'      => ServiceRequest,
  'organizational_units'  => Organization,
  'institutions'          => Institution,
}

def entity_class(type)
  return EntityClasses[type.downcase] || type.classify.constantize
end

class ObisEntity
  def initialize
  end

  def get_all(type)
    klass = entity_class(type)
    result = klass.all
    json = result.to_json(:jsontype => :obisentity)
  end

  def get_one(type, obisid)
    klass = entity_class(type)
    result = klass.find_by_obisid(obisid)

    json = result.to_json(:jsontype => :obisentity)

    return json
  end

  def get_identifiers(name, value)
    result = nil

    Entity.entity_classes.each do |klass|
      if klass.attribute_method?(name) then
        result = klass.where(name => value)
        result = result[0] # should only ever be one?
        break
      end
    end

    json = result.to_json(:jsontype => :obisentity)

    return json
  end

  def put_one(type, obisid, json)
    klass = entity_class(type)
    obj = klass.find_by_obisid(obisid)

    ActiveRecord::Base.transaction do
      obj.update_from_json(json, :jsontype => :obisentity)

      json = obj.to_json(:jsontype => :obisentity)
    end

    json
  end

  def post_one(type, json)
    klass = entity_class(type)

    ActiveRecord::Base.transaction do
      obj = klass.create_from_json(json, :jsontype => :obisentity)

      # TODO: obis-common returns a diff of the original and the new record
      json = obj.to_json(:jsontype => :obisentity)
    end

    json
  end

  def delete_one(type, obisid)
    klass = entity_class(type)
    obj = klass.find_by_obisid(obisid)
    json = klass.find_by_obisid(obisid)

    ActiveRecord::Base.transaction do
      if obj then
        json = obj.destroy_using_json(json, :jsontype => :obisentity)
      else
        json = nil
      end
    end

    json
  end

  def get_all_rel(type)
    klass = entity_class(type)
    result = klass.all
    json = result.to_json(:jsontype => :relationships)
  end

  def get_rel_for_one(type, obisid)
    klass = entity_class(type)
    result = klass.find_by_obisid(obisid)
    json = result.to_json(:jsontype => :relationships)
  end

  def get_one_rel(type, obisid, relid)
    klass = entity_class(type)
    entity = klass.find_by_obisid(obisid)

    relationships = entity.as_json(:jsontype => :relationships)
    relationship = relationships.find { |relationship|
      relationship['rid'] == relid
    }

    json = relationship.to_json()
  end

  def put_one_rel(type, obisid, relid, json)
    klass = entity_class(type)
    json = get_json(params, request)
    entity = klass.find_by_obisid(json['from']) ||
             klass.find_by_obisid(json['to'])

    ActiveRecord::Base.transaction do
      json = entity.update_from_json(
          json,
          jsontype: :relationships,
          rid:      relid)
    end

    json
  end

  def post_one_rel(type, obisid, json)
    klass = entity_class(type)
    obj = klass.find_by_obisid(obisid)

    ActiveRecord::Base.transaction do
      json = obj.create_from_json(json, :jsontype => :relationships)
    end

    json
  end

  def delete_one_rel(type, obisid, relid)
    klass = entity_class(type)
    json = get_json(params, request)
    obj = klass.find_by_obisid(obisid)

    ActiveRecord::Base.transaction do
      json = obj.destroy_using_json(json, :jsontype => :relationships)
    end

    json
  end
end

