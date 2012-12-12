module CatalogManager::CatalogHelper
  def node object, can_access=true, id=nil
    link_to object.name, '#', :id => id, :cid => object.id, :object_type => object.class.to_s.downcase, :class => can_access ? "" : "disabled_node"
  end
  
  def disable_pricing_setup(pricing_setup, can_edit_historical_data)
    begin
      if can_edit_historical_data == false
        (pricing_setup.effective_date <= Date.today) || (pricing_setup.display_date <= Date.today) ? true : false
      else
        false
      end
    rescue
      false
    end
  end

  def disable_pricing_map(pricing_map, can_edit_historical_data)
    if can_edit_historical_data == false
      (pricing_map.effective_date <= Date.today) || (pricing_map.display_date <= Date.today) ? true : false
    else
      false
    end
  end
end
