json.(@responses) do |response|
  srid = response.try(:respondable).try(:display_id) || response.try(:respondable).try(:protocol_id) || 'N/A'

  json.srid             srid == 'N/A' ? 'N/A' : link_to(srid, dashboard_protocol_path(srid.to_s.split('-').first), target: :blank)
  json.short_title      response.try(:respondable).try(:protocol).try(:short_title) || 'N/A'
  json.primary_pi       response.try(:respondable).try(:protocol).try(:primary_principal_investigator).try(:full_name) || 'N/A'
  json.title            response.survey.title
  json.by               response.try(:identity_id).present? ? Identity.find(response.identity_id).full_name : 'N/A'
  json.complete         complete_display(response)            
  json.completion_date  format_date(response.created_at)
  json.actions          response_options(response)
end
