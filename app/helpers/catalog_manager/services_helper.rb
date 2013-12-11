module CatalogManager::ServicesHelper
  def display_service_user_rights user, form_name, organization
    if user.can_edit_entity? organization
      render form_name
    else
      content_tag(:h1, "Sorry, you are not allowed to access this page.") +
      content_tag(:h3, "Please contact your system administrator.", :style => 'color:#999')
    end
  end

  def display_otf_attributes pricing_map
    if pricing_map
      attributes = ""
      if pricing_map.is_one_time_fee
        if pricing_map.otf_unit_type == "N/A"
          attributes = "# " + pricing_map.quantity_type
        else
          attributes = "# " + pricing_map.quantity_type + " /  # " + pricing_map.otf_unit_type
        end
      end

      attributes
    end
  end

  #TODO May eventually use this to clean up the pricing map view
  # def otf_display_style pricing_map
  #   style = ""

  #   if pricing_map
  #     unless pricing_map.is_one_time_fee
  #       style = "display:none;"
  #     end
  #   else
  #     style = "display:none;"
  #   end

  #   style
  # end

  def validate_per_patient pricing_map
    if pricing_map
      validate = ""
      unless pricing_map.is_one_time_fee
        validate = "validate"
      end

      validate
    end
  end
end
