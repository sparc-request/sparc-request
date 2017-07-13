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
    @organization.available_statuses.destroy_all
    @organization.editable_statuses.destroy_all
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
      @params[:pricing_setups].each do |_, ps|
        if ps['id'].blank?
          ps.delete("id")
          ps.delete("newly_created")
          @organization.pricing_setups.build(pricing_setups_params(pricing_setups_params(ps)))
        else
          # @organization.pricing_setups.find(ps['id']).update_attributes(ps)
          ps_id = ps['id']
          ps.delete("id")
          @organization.pricing_setups.find(ps_id).update_attributes(pricing_setups_params(ps))
        end
        @organization.save
      end
    end
  end

  private

  def pricing_setups_params(ps)
    ps.permit(:organization_id,
      :display_date,
      :effective_date,
      :charge_master,
      :federal,
      :corporate,
      :other,
      :member,
      :college_rate_type,
      :federal_rate_type,
      :foundation_rate_type,
      :industry_rate_type,
      :investigator_rate_type,
      :internal_rate_type,
      :unfunded_rate_type)
  end
end
