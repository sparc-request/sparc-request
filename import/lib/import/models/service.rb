class Service::ObisEntitySerializer < Entity::ObisEntitySerializer
  def as_json(service, options = nil)
    h = super(service, options)

    optional_attributes = {
      'name'                 => service.name,
      'abbreviation'         => service.abbreviation,
      'order'                => service.order,
      'description'          => service.description,
      'is_available'         => service.is_available,
      'service_center_cost'  => service.service_center_cost,
      'cpt_code'             => service.cpt_code,
      'charge_code'          => service.charge_code,
      'revenue_code'         => service.revenue_code,
      'pricing_maps'         => service.pricing_maps.as_json(options),
    }

    optional_attributes.delete_if { |k, v| v.nil? }

    h['attributes'].update(optional_attributes)

    return h
  end

  def update_attributes_from_json(entity, h, options = nil)
    super(entity, h, options)

    identifiers = h['identifiers']
    attributes = h['attributes']

    entity.update_attributes!(
        :name => attributes['name'],
        :abbreviation => attributes['abbreviation'],
        :order => attributes['order'],
        :description => attributes['description'],
        :is_available => attributes['is_available'],
        :service_center_cost => attributes['service_center_cost'],
        :cpt_code => attributes['cpt_code'],
        :charge_code => attributes['charge_code'],
        :revenue_code => attributes['revenue_code'])

    # Delete all pricing maps for the service; they will be
    # re-created in the next step.
    entity.pricing_maps.each do |pricing_map|
      pricing_map.destroy()
    end

    # Create a new pricing map for each one that is passed in.
    (attributes['pricing_maps'] || [ ]).each do |h_pricing_map|
      pricing_map = entity.pricing_maps.create()
      pricing_map.update_from_json(h_pricing_map, options)
    end
  end
end

class Service
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
end

