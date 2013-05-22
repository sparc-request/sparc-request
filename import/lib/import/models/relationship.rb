# Here's an abstraction for serializing relationships to json.
#
# An example of a relationship is project_role.  It maps an identity to
# an project/study via the project_roles table.  The json for this
# relationship looks something like this:
#
# {
#    "type"              : "relationship",
#    "relationship_type" : "project_role",
#    "from"              : "5f0b6e30e3aa70ec08eb8f9f313913e4",
#    "to"                : "0f6a4d750fd369ff4ae40937300fa25c"
#    "relationship_id"   : "12345",
#    "attributes" : {
#      "id"             : "0f6a4d750fd369ff4ae40937300fa25c",
#      "project_rights" : "approve",
#      "role"           : "research-assistant-coordinator"
#    },
# }
#
# We need to handle both serialization to json and deserialization from
# json.  This abstraction does both.  To use it, first specify the
# relationship type, and which ActiveRecord classes the relationship
# maps from and to:
#
#   class ProjectRole < Relationship
#     type 'project_role'
#     from Identity
#     to   Protocol
#   end
#
# Next, define methods to find relationships for an entity:
#
#   * self.from_relationships(entity) - given an entity, returns an
#     array of Relationship instances for which that entity is the
#     'from' member of a relationship.
#
#   * self.to_relationships(entity) - given an entity, returns an array
#     of Relationship instances for which that entity is the 'to' member
#     of a relationship.
#
# And methods used in serialization and deserialization:
#
#   * as_json(options) - returns a data structure that can trivially be
#     serialized to json (probably a Hash).
#
#   * self.update_from_json(h, options) - given the data structure
#     returned by as_json, update the corresponding tables.  It can be
#     assumed that this method is called from inside a transaction.
#
#   * self.find_relationship(id) - given a relationship id, return a
#     Relationship instance.
#
#   * self.create_relationship(h) - given the data structure returned by
#     as_json, create a new Relationship instance and return it.
#
# Finally, ensure that the ActiveRecord class includes the Entity module
# and defines the appropriate serializer:
#
# class Identity
#   include Entity
#   include JsonSerializable
#   json_serializer :relationships, RelationshipsSerializer
# end

# A helper class used in defining relationships.
module Relates
  module RelatesRegistrar
    def from_relationship_classes
      @from_relationship_classes ||= [ ]

      result = @from_relationship_classes.dup

      if self.superclass.respond_to?(:from_relationship_classes) then
        result.concat(self.superclass.from_relationship_classes)
      end

      return result
    end

    def to_relationship_classes
      @to_relationship_classes ||= [ ]

      result = @to_relationship_classes.dup

      if self.superclass.respond_to?(:to_relationship_classes) then
        result.concat(self.superclass.to_relationship_classes)
      end

      return result
    end

    # Register a Relationship class indicating that this class is the
    # 'from' member in a relationship.  This method should not normally
    # be called by the user.
    def add_from_relationship(klass)
      @from_relationship_classes ||= [ ]
      @from_relationship_classes << klass
    end

    # Register a Relationship class indicating that this class is the
    # 'to' member in a relationship.  This method should not normally
    # be called by the user.
    def add_to_relationship(klass)
      @to_relationship_classes ||= [ ]
      @to_relationship_classes << klass
    end
  end
 
  # Given an entity, returns an array of Relationship instances for
  # which that entity is the 'from' member of a relationship.
  def from_relationships
    result = [ ]

    self.class.from_relationship_classes.each do |klass|
      result.concat(klass.from_relationships(self))
    end

    return result
  end

  # Given an entity, returns an array of Relationship instances for
  # which that entity is the 'to' member of a relationship.
  def to_relationships
    result = [ ]

    self.class.to_relationship_classes.each do |klass|
      result.concat(klass.to_relationships(self))
    end

    return result
  end

  def self.included(klass)
    klass.extend RelatesRegistrar
  end
end

# Serializer for relationships for classes which include the Entity
# module.
class Entity::RelationshipsSerializer
  # Return all the entity's relationships to a structure that can
  # trivially be serialized to json.
  def as_json(entity, options = nil)
    result = [ ]

    from_relationships = entity.from_relationships()
    to_relationships   = entity.to_relationships()

    result.concat(from_relationships.map { |rel| rel.as_json(options) })
    result.concat(to_relationships.map   { |rel| rel.as_json(options) })

    return result
  end

  # given the data structure structure returned by as_json, update the
  # corresponding tables.  It can be assumed that this method is called
  # from inside a transaction.
  def update_from_json(entity, h, options = nil)
    klass = Relationship.classes[h['relationship_type']]
    raise ArgumentError, "No relationship class found for #{h['relationship_type'].inspect}" if not klass

    result = klass.update_from_json(h, options)
    return result
  end

  def create_from_json(entity, h, options = nil)
    klass = Relationship.classes[h['relationship_type']]
    raise ArgumentError, "No relationship class found for #{h['relationship_type'].inspect}" if not klass

    result = klass.create_from_json(h, options)
    return result
  end
end

# Base class for all relationships.
class Relationship
  @classes = { }

  class << self
    attr_reader :classes
    attr_reader :relationship_type
    attr_reader :from_model
    attr_reader :to_model
  end

  # Define the relationship type.
  def self.type(type)
    @relationship_type = type
    Relationship.classes[type] = self
  end

  # Define the 'from' entity of the relationship.
  def self.from(klass)
    @from_model = klass
    klass.add_from_relationship(self)
  end

  # Define the 'to' entity of the relationship.
  def self.to(klass)
    @to_model = klass
    klass.add_to_relationship(self)
  end

  # Helper method for building a relationship Hash.
  def relationship(opts)
    relationship = {
      'relationship_id'    => opts[:rid],
      'type'               => 'relationship',
      'relationship_type'  => self.class.relationship_type,
      'from'               => opts[:from].obisid,
      'to'                 => opts[:to].obisid,
    }

    if attrs = opts[:attributes] then
      relationship['attributes'] = attrs
    end

    return relationship
  end

  # Update the relationship found in `model` with the attributes as
  # specified in `args`.  Checks the given json hash to see if
  # timestamps should be updated.
  #
  # This method is called by the derived Relationship class when it
  # wants to update a table.  Updating the table by calling
  # update_attributes directly will result in incorrect timestamp
  # behavior.
  #
  # This method should not normally be called by an outside class.
  def update_relationship(h, model, attributes)
    orig_record_timestamps = model.record_timestamps
    model.record_timestamps = false if h['override_updated_at']
    begin
      has_timestamps = attributes.delete(:has_timestamps)
      model.attributes = attributes
      if has_timestamps then
        model.created_at = h['created_at'] ? Time.parse(h['created_at']) : Time.now
        model.updated_at = h['updated_at'] ? Time.parse(h['updated_at']) : Time.now
      end
      model.save!(:validate => false) # TODO: any way to do the import _with_ validations?
    ensure
      model.record_timestamps = orig_record_timestamps
    end
  end

  # Find the relationship in the database and update it with the data in
  # the given hash.
  def self.update_from_json(h, options = nil)
    relationship = self.find_relationship(h['relationship_id'])
    relationship.update_from_json(h, options)
    return relationship.to_json(options)
  end

  # Create a new relationship in the database with the data from the
  # given hash.
  def self.create_from_json(h, options = nil)
    relationship = self.create_relationship(h)
    relationship.update_from_json(h, options)
    return relationship.to_json(options)
  end
end

class Identity < ActiveRecord::Base
  include Relates
end

class Organization < ActiveRecord::Base
  include Relates
end

class Core < Organization
end

class Program < Organization
end

class Provider < Organization
end

class Institution < Organization
end

class ServiceRequest < ActiveRecord::Base
  include Relates
end

class Protocol < ActiveRecord::Base
  include Relates
end

class Service < ActiveRecord::Base
  include Relates
end

class SuperUserOrganizationalUnit < Relationship
  type 'super_user_organizational_unit'
  from Identity
  to   Organization

  def self.from_relationships(identity)
    return identity.super_users.map { |super_user| self.new(super_user) }
  end

  def self.to_relationships(organization)
    return organization.super_users.map { |super_user| self.new(super_user) }
  end

  def initialize(super_user)
    @super_user = super_user
  end

  def as_json(options = nil)
    return relationship(
        from: @super_user.identity,
        to:   @super_user.organization,
        rid:  @super_user.id)
  end

  def self.find_relationship(id)
    super_user = SuperUser.find_by_id(id)
    return self.new(super_user)
  end

  def self.create_relationship(h)
    super_user = SuperUser.create()
    return self.new(super_user)
  end

  def update_from_json(h, options = nil)
    identity = Identity.find_by_obisid(h['from'])
    organization = Organization.find_by_obisid(h['to'])
    update_relationship(
        h,
        @super_user,
        has_timestamps:   true,
        identity_id:      identity.id,
        organization_id:  organization.id)
  end
end

class ClinicalProviderOrganizationalUnit < Relationship
  type 'clinical_provider_organizational_unit'
  from Identity
  to   Organization

  def self.from_relationships(identity)
    return identity.clinical_providers.map { |clinical_provider| self.new(clinical_provider) }
  end

  def self.to_relationships(organization)
    return organization.clinical_providers.map { |clinical_provider| self.new(clinical_provider) }
  end

  def initialize(clinical_provider)
    @clinical_provider = clinical_provider
  end

  def as_json(options = nil)
    return relationship(
        from: @clinical_provider.identity,
        to:   @clinical_provider.organization,
        rid:  @clinical_provider.id)
  end

  def self.find_relationship(id)
    clinical_provider = ClinicalProvider.find_by_id(id)
    return self.new(clinical_provider)
  end

  def self.create_relationship(h)
    clinical_provider = ClinicalProvider.create()
    return self.new(clinical_provider)
  end

  def update_from_json(h, options = nil)
    identity = Identity.find_by_obisid(h['from'])
    organization = Organization.find_by_obisid(h['to'])
    update_relationship(
        h,
        @clinical_provider,
        has_timestamps:   true,
        identity_id:      identity.id,
        organization_id:  organization.id)
  end
end

class ServiceProviderOrganizationalUnit < Relationship
  type 'service_provider_organizational_unit'
  from Identity
  to   Organization

  def self.from_relationships(identity)
    service_providers = ServiceProvider.find_all_by_identity_id(identity.id)
    return service_providers.map { |service_provider| self.new(service_provider) }
  end

  def self.to_relationships(organization)
    service_providers = organization.service_providers
    return service_providers.map { |service_provider| self.new(service_provider) }
  end

  def initialize(service_provider)
    @service_provider = service_provider
  end

  def as_json(options = nil)
    return relationship(
        from: @service_provider.identity,
        to:   @service_provider.organization,
        rid:  @service_provider.id,
        attributes: {
          'is_primary_contact' => @service_provider.is_primary_contact ? true : false,
          'hold_emails'        => @service_provider.hold_emails ? true : false,
        })
  end

  def self.find_relationship(id)
    service_provider = ServiceProvider.find_by_id(id)
    return self.new(service_provider)
  end

  def self.create_relationship(h)
    identity = Identity.find_by_obisid(h['from'])
    organization = Organization.find_by_obisid(h['to'])
    service_provider = ServiceProvider.create()
    return self.new(service_provider)
  end

  def update_from_json(h, options = nil)
    attributes = h['attributes'] || { }
    identity = Identity.find_by_obisid(h['from'])
    organization = Organization.find_by_obisid(h['to'])
    update_relationship(
        h,
        @service_provider,
        has_timestamps:     true,
        identity_id:        identity.id,
        organization_id:    organization.id,
        is_primary_contact: attributes['is_primary_contact'],
        hold_emails:        attributes['hold_emails'])
  end
end

class CatalogManagerOrganizationalUnit < Relationship
  type 'catalog_manager_organizational_unit'
  from Identity
  to   Organization

  def self.from_relationships(identity)
    catalog_managers = CatalogManager.find_all_by_identity_id(identity.id)
    return catalog_managers.map { |catalog_manager| self.new(catalog_manager) }
  end

  def self.to_relationships(organization)
    catalog_managers = organization.catalog_managers
    return catalog_managers.map { |catalog_manager| self.new(catalog_manager) }
  end

  def initialize(catalog_manager)
    @catalog_manager = catalog_manager
  end

  def as_json(options = nil)
    return relationship(
        from: @catalog_manager.identity,
        to:   @catalog_manager.organization,
        rid:  @catalog_manager.id,
        attributes: {
          'edit_historic_data' => @catalog_manager.edit_historic_data ? true : false,  
        })
  end

  def self.find_relationship(id)
    catalog_manager = CatalogManager.find_by_id(id)
    return self.new(catalog_manager)
  end

  def self.create_relationship(h)
    catalog_manager = CatalogManager.create()
    return self.new(catalog_manager)
  end

  def update_from_json(h, options = nil)
    attributes = h['attributes'] || { }
    identity = Identity.find_by_obisid(h['from'])
    organization = Organization.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find identity with obisid #{h['from']}" if not identity
    raise ArgumentError, "Could not find organization with obisid #{h['to']}" if not organization

    update_relationship(
        h,
        @catalog_manager,
        has_timestamps:    true,
        identity_id:       identity.id,
        organization_id:   organization.id,
        edit_historic_data: attributes['edit_historic_data'])
  end
end

class ServiceRequestOwner < Relationship
  type 'service_request_owner'
  from ServiceRequest
  to   Identity

  def self.from_relationships(service_request)
    sub_service_requests = service_request.sub_service_requests
    sub_service_requests.reject! { |ssr| ssr.owner.nil? }
    return sub_service_requests.map { |ssr| self.new(ssr) }
  end

  def self.to_relationships(identity)
    sub_service_requests = SubServiceRequest.find_all_by_owner_id(identity.id)
    return sub_service_requests.map { |ssr| self.new(ssr) }
  end

  def initialize(sub_service_request)
    @sub_service_request = sub_service_request
  end

  def as_json(options = nil)
    return relationship(
        from: @sub_service_request.service_request,
        to:   @sub_service_request.owner,
        rid:  @sub_service_request.id,
        attributes: {
          'sub-service-request-id' => @sub_service_request.ssr_id,
        })
  end

  def self.find_relationship(id)
    sub_service_request = SubServiceRequest.find_by_id(id)
    return self.new(sub_service_request)
  end

  def self.create_relationship(h)
    sub_service_request_id = h['attributes']['sub-service-request-id']

    service_request = ServiceRequest.find_by_obisid(h['from'])
    raise ArgumentError, "Could not find service request with obisid #{h['from']}" if not service_request

    sub_service_request = SubServiceRequest.find_or_create_by_ssr_id_and_service_request_id(
        sub_service_request_id,
        service_request.id)

    return self.new(sub_service_request)
  end

  def update_from_json(h, options = nil)
    attributes = h['attributes']
    service_request = ServiceRequest.find_by_obisid(h['from'])
    owner = Identity.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find service request with obisid #{h['from']}" if not service_request
    raise ArgumentError, "Could not find identity with obisid #{h['to']}" if not owner

    update_relationship(
        h,
        @sub_service_request,
        service_request_id: service_request.id,
        owner_id:           owner.id,
        ssr_id:             attributes['sub-service-request-id'])
  end
end

class ProjectRoleRelationship < Relationship
  type 'project_role'
  from Protocol
  to   Identity

  def self.from_relationships(protocol)
    return protocol.project_roles.map { |project_role| self.new(project_role) }
  end

  def self.to_relationships(identity)
    return identity.project_roles.map { |project_role| self.new(project_role) }
  end

  def initialize(project_role)
    @project_role = project_role
  end

  def as_json(options = nil)
    attrs = { 
      'id'             => @project_role.identity.obisid,
      'project_rights' => @project_role.project_rights,
      'role'           => @project_role.role,
    }

    attrs.delete_if { |k, v| v.nil? }

    return relationship(
        from: @project_role.protocol,
        to:   @project_role.identity,
        rid:  @project_role.id,
        attributes: attrs)
  end

  def self.find_relationship(id)
    project_role = ProjectRole.find_by_id(id)
    return self.new(project_role)
  end

  def self.create_relationship(h)
    project_role = ProjectRole.create()
    return self.new(project_role)
  end

  def update_from_json(h, options = nil)
    attributes = h['attributes']
    protocol = Protocol.find_by_obisid(h['from'])
    identity = Identity.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find protocol with obisid #{h['from']}" if not protocol
    raise ArgumentError, "Could not find identity with obisid #{h['to']}" if not identity

    update_relationship(
        h,
        @project_role,
        has_timestamps:   true,
        protocol_id:      protocol.id,
        identity_id:      identity.id,
        project_rights:   attributes['project_rights'],
        role:             attributes['role'])

    if attributes['subspecialty'] then
      update_relationship(
          h,
          identity,
          has_timestamps: false,
          subspecialty:   attributes['subspecialty'])
    end

    # TODO: we don't update the obisid here (attributes['id']) because:
    # 1) it's not always present in the couch database
    # 2) it's probably not the behavior we want anyway
  end
end

# This class is a special case.  It has two concrete derived classes,
# CoreServiceOffering and ProgramServiceOffering.  It is not possible to
# combine these into a single class, because it would break the hash
# lookup from relationship type string to relationship class.
class ServiceOffering < Relationship
  def self.from_relationships(service)
    # if we don't do this check, then we'll get duplicates for
    # CoreServiceOffering and ProgramServiceOffering
    if service.organization and service.organization.type == to_model.name then
      return [ self.new(service, service.organization) ]
    else
      return [ ]
    end
  end

  def self.to_relationships(organization)
    return organization.services.map { |service| self.new(service, organization) }
  end

  def initialize(service, organization)
    @service = service
    @organization = organization
  end

  def as_json(options = nil)
    type = @organization.type.downcase
    rel = relationship(
        from: @service,
        to:   @organization,
        rid:  "#{@service.id}:#{@organization.id}")
  end

  def self.find_relationship(id)
    service_id, organization_id = id.split(':', 2)
    service = Service.find_by_id(service_id)
    organization = Organization.find_by_id(organization_id)
    return self.new(service, organization)
  end

  def self.create_relationship(h)
    service = Service.find_by_obisid(h['from'])
    organization = Organization.find_by_obisid(h['to'])
    return self.new(service, organization)
  end

  def update_from_json(h, options = nil)
    new_service = Service.find_by_obisid(h['from'])
    new_organization = Organization.find_by_obisid(h['to'])

    raise ArgumentError "Could not find service with obisid #{h['from']}" if not new_service
    raise ArgumentError, "Could not find organization with obisid #{h['to']}" if not new_organization

    if @service.id != new_service.id then
      update_relationship(
          h,
          @service,
          organization_id: nil)
    end

    update_relationship(
        h,
        new_service,
        organization_id: @organization.id)

    # now update the is_available attribute
    # it needs to be set to the organization's is_available attribute if
    # it is not set at all
    if new_service.is_available == nil then
      update_relationship(
          h,
          new_service,
          is_available: @organization.is_available)
    end
  end
end

class CoreServiceOffering < ServiceOffering
  type 'core_service_offering'
  from Service
  to   Core
end

class ProgramServiceOffering < ServiceOffering
  type 'program_service_offering'
  from Service
  to   Program
end

class ProgramMembership < Relationship
  type 'program_membership'
  from Core
  to   Program

  def self.from_relationships(core)
    if core.program then
      return [ self.new(core, core.program) ]
    else
      # orphaned core
      return [ ]
    end
  end

  def self.to_relationships(program)
    return program.cores.map { |core| self.new(core, program) }
  end

  def initialize(core, program)
    @core = core
    @program = program
  end

  def as_json(options = nil)
    return relationship(
        type: 'program_membership',
        from: @core,
        to:   @program,
        rid:  "#{@core.id}:#{@program.id}")
  end

  def self.find_relationship(id)
    core_id, program_id = id.split(':', 2)
    core = Core.find_by_id(core_id)
    program = Program.find_by_id(program_id)
    return self.new(core, program)
  end

  def self.create_relationship(h)
    core = Core.find_by_obisid(h['from'])
    program = Program.find_by_obisid(h['to'])
    return self.new(core, program)
  end

  def update_from_json(h, options = nil)
    new_core = Core.find_by_obisid(h['from'])
    new_program = Program.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find core with obisid #{h['from']}" if not new_core
    raise ArgumentError, "Could not find program with obisid #{h['to']}" if not new_program

    if @core.id != new_core.id then
      update_relationship(
          h,
          @core,
          parent_id: nil) # TODO: this interface allows us to create an orphaned core
    end

    update_relationship(
        h,
        new_core,
        parent_id: new_program.id)
  end
end

class ProviderMembership < Relationship
  type 'provider_membership'
  from Program
  to   Provider

  def self.from_relationships(program)
    if program.provider then
      return [ self.new(program, program.provider) ]
    else
      # orphaned program
      return [ ]
    end
  end

  def self.to_relationships(provider)
    return provider.programs.map { |program| self.new(program, provider) }
  end

  def initialize(program, provider)
    @program = program
    @provider = provider
  end

  def as_json(options = nil)
    return relationship(
        type: 'program_membership',
        from: @program,
        to:   @provider,
        rid:  "#{@program.id}:#{@provider.id}")
  end

  def self.find_relationship(id)
    program_id, provider_id = id.split(':', 2)
    program = Program.find_by_id(program_id)
    provider = Provider.find_by_id(provider_id)
    return self.new(program, provider)
  end

  def self.create_relationship(h)
    program = Program.find_by_obisid(h['from'])
    provider = Provider.find_by_obisid(h['to'])
    return self.new(program, provider)
  end

  def update_from_json(h, options = nil)
    new_program = Program.find_by_obisid(h['from'])
    new_provider = Provider.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find program with obisid #{h['from']}" if not new_program
    raise ArgumentError, "Could not find provider with obisid #{h['to']}" if not new_provider

    if @program.id != new_program.id then
      update_relationship(
          h,
          @program,
          parent_id: nil) # TODO: this interface allows us to create an orphaned program
    end

    update_relationship(
        h,
        new_program,
        parent_id: new_provider.id)
  end
end

class InstitutionMembership < Relationship
  type 'institution_membership'
  from Provider
  to   Institution

  def self.from_relationships(provider)
    if provider.institution then
      return [ self.new(provider, provider.institution) ]
    else
      # orphaned provider
      return [ ]
    end
  end

  def self.to_relationships(institution)
    return institution.providers.map { |provider| self.new(provider, institution) }
  end

  def initialize(provider, institution)
    @provider = provider
    @institution = institution
  end

  def as_json(options = nil)
    return relationship(
        type: 'provider_membership',
        from: @provider,
        to:   @institution,
        rid:  "#{@provider.id}:#{@institution.id}")
  end

  def self.find_relationship(id)
    provider_id, institution_id = id.split(':', 2)
    provider = Provider.find_by_id(provider_id)
    institution = Institution.find_by_id(institution_id)
    return self.new(provider, institution)
  end

  def self.create_relationship(h)
    provider = Provider.find_by_obisid(h['from']) or raise ArgumentError, "Could not find provider with obisid #{h['from']}"
    institution = Institution.find_by_obisid(h['to']) or raise ArgumentError, "Could not find institution with obisid #{h['to']}"
    return self.new(provider, institution)
  end

  def update_from_json(h, options = nil)
    new_provider = Provider.find_by_obisid(h['from']) or raise ArgumentError, "Could not find provider with obisid #{h['from']}"
    new_institution = Institution.find_by_obisid(h['to']) or raise ArgumentError, "Could not find institution with obisid #{h['to']}"

    if @provider.id != new_provider.id then
      update_relationship(
          h,
          @provider,
          parent_id: nil) # TODO: this interface allows us to create an orphaned provider
    end

    update_relationship(
        h,
        new_provider,
        parent_id: new_institution.id)
  end
end

class ProjectServiceRequestMembership < Relationship
  type 'project_service_request_membership'
  from ServiceRequest
  to   Protocol

  def self.from_relationships(service_request)
    if service_request.protocol then
      return [ self.new(service_request, service_request.protocol) ]
    else
      return [ ]
    end
  end

  def self.to_relationships(protocol)
    return protocol.service_requests.map { |service_request| self.new(service_request, protocol) }
  end

  def initialize(service_request, protocol)
    @service_request = service_request
    @protocol = protocol
  end

  def as_json(options = nil)
    return relationship(
        type: 'project_service_request_membership',
        from: @service_request,
        to:   @protocol,
        rid:  "#{@service_request.id}:#{@protocol.id}")
  end

  def self.find_relationship(id)
    service_request_id, protocol_id = id.split(':', 2)
    service_request = ServiceRequest.find_by_id(service_request_id)
    protocol = Protocol.find_by_id(protocol_id)

    raise ArgumentError, "Could not find service request with id #{service_request_id}" if not service_request
    raise ArgumentError, "Could not find protocol with id #{protocol}" if not protocol

    return self.new(service_request, protocol)
  end

  def self.create_relationship(h)
    service_request = ServiceRequest.find_by_obisid(h['from'])
    protocol = Protocol.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find service request with id #{service_request_id}" if not service_request
    raise ArgumentError, "Could not find protocol with id #{protocol}" if not protocol

    return self.new(service_request, protocol)
  end

  def update_from_json(h, options = nil)
    new_service_request = ServiceRequest.find_by_obisid(h['from'])
    new_protocol = Protocol.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find service request with obisid #{h['from']}" if not new_service_request
    raise ArgumentError, "Could not find protocol with obisid #{h['to']}" if not new_protocol

    if @service_request.id != new_service_request.id then
      update_relationship(
          h,
          @service_request,
          protocol_id: nil)
    end

    update_relationship(
        h,
        new_service_request,
        protocol_id: new_protocol.id)
  end
end

class AssociatedService < Relationship
  type 'associated_service'
  from Service
  to   Service

  def self.from_relationships(service)
    return service.service_relations.map { |service_relation| self.new(service_relation) }
  end

  def self.to_relationships(service)
    return service.depending_service_relations.map { |service_relation| self.new(service_relation) }
  end

  def initialize(service_relation)
    @service_relation = service_relation
  end

  def as_json(options = nil)
    return relationship(
        from: @service_relation.service,
        to:   @service_relation.related_service,
        rid:  @service_relation.id,
        attributes: {
          'optional' => @service_relation.optional
        })
  end

  def self.find_relationship(id)
    service_relation = ServiceRelation.find_by_id(id)
    raise ArgumentError, "Could not find service relation with id #{id}" if not service_relation
    return self.new(service_relation)
  end

  def self.create_relationship(h)
    service_relation = ServiceRelation.create(id: h['id'])
    return self.new(service_relation)
  end

  def update_from_json(h, options = nil)
    attributes = h['attributes']
    from_service = Service.find_by_obisid(h['from'])
    to_service = Service.find_by_obisid(h['to'])

    raise ArgumentError, "Could not find service with obisid #{h['from']}" if not from_service
    raise ArgumentError, "Coult not find service with obisid #{h['to']}" if not to_service

    update_relationship(
        h,
        @service_relation,
        has_timestamps:     true,
        service_id:         from_service.id,
        related_service_id: to_service.id,
        optional:           attributes['optional'])
  end
end

