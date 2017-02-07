class OrganizationUpdater

  def initialize(attributes, organization, params)
    @attributes = attributes
    @organization = organization
    @params = params
  end

  def set_org_tags
    unless @attributes[:tag_list] || @organization.type == 'Institution'
      @attributes[:tag_list] = ""
    end

    @attributes
  end

  def update_organization
    @attributes.delete(:id)
    name_change = @attributes[:name] != @organization.name || @attributes[:abbreviation] != @organization.abbreviation

    # Update its Services
    services_updated = if @params[:switch_all_services]
                         service_availability = (@params[:switch_all_services] == "on")
                         @organization.services.all? { |service| service.update(is_available: service_availability) }
                       else
                         true
                       end

    if services_updated && @organization.update_attributes(@attributes)
      @organization.update_ssr_org_name if name_change
      @organization.update_descendants_availability(@attributes[:is_available])

      true
    else

      false
    end
  end

  def save_pricing_setups
    if @params[:pricing_setups] && ['Program', 'Provider'].include?(@organization.type)
      @params[:pricing_setups].each do |ps|
        if ps[1]['id'].blank?
          ps[1].delete(:id)
          ps[1].delete(:newly_created)
          @organization.pricing_setups.build(ps[1])
        else
          # @organization.pricing_setups.find(ps[1]['id']).update_attributes(ps[1])
          ps_id = ps[1]['id']
          ps[1].delete(:id)
          @organization.pricing_setups.find(ps_id).update_attributes(ps[1])
        end
        @organization.save
      end
    end
  end
end
