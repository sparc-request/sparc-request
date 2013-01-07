class Organization::ObisEntitySerializer < Entity::ObisEntitySerializer
  def as_json(entity, options = nil)
    h = super(entity, options)

    optional_attributes = {
      'name'               => entity.name,
      'order'              => entity.order,
      'css_class'          => entity.css_class,
      'description'        => entity.description,
      'abbreviation'       => entity.abbreviation,
      'ack_language'       => entity.ack_language,
      'process_ssrs'       => entity.process_ssrs,
      'is_available'       => entity.is_available ? true : false,
      'subsidy_map'        => entity.subsidy_map.as_json(options),
      'submission_emails'  => entity.submission_emails.as_json(options)
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
        :name          => attributes['name'],
        :order         => attributes['order'],
        :css_class     => attributes['css_class'],
        :description   => attributes['description'],
        :abbreviation  => attributes['abbreviation'],
        :ack_language  => attributes['ack_language'],
        :process_ssrs  => attributes['process_ssrs'],
        :is_available  => attributes['is_available']
    )

    entity.build_subsidy_map() if not entity.subsidy_map
    if attributes['subsidy_map'] then
      entity.subsidy_map.update_from_json(
          attributes['subsidy_map'],
          options)
    else
      entity.subsidy_map.destroy() if entity.subsidy_map
    end

    # Delete all submission emails for the organization; they will be
    # re-created in the next step.
    entity.submission_emails.each do |submission_email|
      submission_email.destroy()
    end

    # Create a new SubmissionEmail for each one that is passed in.
    (attributes['submission_emails'] || [ ]).each do |h_submission_email|
      submission_email = entity.submission_emails.create()
      submission_email.update_from_json(h_submission_email, options)
    end
  end

  # The user might try to POST to an obisentity/organizational_units
  # url, so we need to instantiate the right Organization subclass in
  # order for the 'type' field to be set.
  def self.create_from_json(entity_class, h, options = nil)
    type = h['classes'][0]
    klass = type.classify.constantize
    obj = klass.new
    obj.update_from_json(h, options)
    return obj
  end
end

class Organization
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
end

