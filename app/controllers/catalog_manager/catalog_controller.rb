class CatalogManager::CatalogController < CatalogManager::AppController
  respond_to :js, :haml, :json

  def index
    @institutions = Institution.order('`order`')
  end
  
  def update_pricing_maps
    percentage = params[:percentage]
    effective_date = params[:effective_date]
    display_date = params[:display_date]    
    entity_id = params[:entity_id]
    
    organization = Organization.find(entity_id)
    services = organization.all_child_services
    @entity = organization
    
    services_not_updated = []
    services.each do |service|
      old_effective_dates = service.pricing_maps.map{ |pm| pm.effective_date }
      old_display_dates = service.pricing_maps.map{ |pm| pm.display_date }
      if old_effective_dates.include?(effective_date.to_date) || old_display_dates.include?(display_date.to_date)
        services_not_updated << service.name
      else
        service.increase_decrease_pricing_map(percentage, display_date, effective_date)
      end
    end
    
    if services_not_updated.empty?
      @rsp = "Successfully updated the pricing maps for all of the services under #{@entity.name}."
    else
      @rsp = "Successfully updated the pricing maps for all of the services under #{@entity.name} except for the following: #{services_not_updated.join(', ')}"
    end
    
  end
  
  def update_rate(pricing_map, rate_type, percentage)
    if pricing_map.try(:[], "#{rate_type}_rate") && !pricing_map.try(:[], "#{rate_type}_rate").try(:blank?)
      change_number = pricing_map.try(:[], "#{rate_type}_rate") * (percentage.to_f * 0.01)
      pricing_map["#{rate_type}_rate"] = change_number + pricing_map.try(:[], "#{rate_type}_rate")
    end
  end

  def verify_valid_pricing_setups
    ps_array = Catalog.invalid_pricing_setups_for(@user)
    render :text => ps_array.empty? ? 'true' : ps_array.map(&:name).join(', ') + ' have invalid pricing setups'
  end
  
  def validate_pricing_map_dates
    selector = params[:str]
    entity_id = params[:entity_id]
    _date = params[:date].match(/(\d?\d)\/(\d?\d)\/(\d{4})/)
    date = Date.parse("#{_date[2]}/#{_date[1]}/#{_date[3]}")
    
    services = Organization.find(entity_id).all_child_services
    there_is_a_same_date = 'false'
    later_dates_exist = 'false'
    services.each do |service|
      service.pricing_maps.each do |pm|
        pricing_map_date = Date.parse(pm.send(selector).to_s)
        if pricing_map_date == date
          there_is_a_same_date = 'true'
        elsif pricing_map_date > date
          later_dates_exist = 'true'
        end
      end
    end

    return_error_string = {:same_dates => there_is_a_same_date, :later_dates => later_dates_exist}
    render :json => return_error_string.to_json
  end  

  def update_dates_on_pricing_maps
    entity_id = params[:entity_id]
    old_value = params[:old_value]
    old_value_type = params[:old_value_type]
    new_value = params[:new_value]

    services = Organization.find(entity_id).all_child_services
    
    services.each do |service|
      service.pricing_maps.each do |pm|
        if Date.parse(old_value.to_s) == Date.parse(pm.try(:[], old_value_type).to_s)
          pm[old_value_type] = new_value 
          pm.save
        end
      end
      service.save!
    end
    
    render :text => ""
  end
  
  def add_excluded_funding_source
    org_id = params[:org_id]
    funding_source = params[:funding_source]
    @organization = case params[:org_type]
    when 'Provider'
      Provider
    when 'Program'
      Program
    when 'Core'
      Core
    end.find(org_id)

    funding_sources = @organization.subsidy_map.excluded_funding_sources
    if funding_sources.map(&:funding_source).include?(funding_source)
      @rsp = false
    else
      @rsp = true
      @funding_source = funding_sources.create({:funding_source => funding_source})
    end
  end
  
  def remove_excluded_funding_source
    @excluded_funding_source = ExcludedFundingSource.find(params[:funding_source_id])
    @excluded_funding_source.delete
    render :nothing => true
  end
end
