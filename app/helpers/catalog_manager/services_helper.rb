module CatalogManager::ServicesHelper
  def display_service_user_rights user, form_name, organization
    if user.can_edit_entity? organization
      render form_name
    else
      content_tag(:h1, "Sorry, you are not allowed to access this page.") +
      content_tag(:h3, "Please contact your system administrator.", :style => 'color:#999')
    end
  end
end
