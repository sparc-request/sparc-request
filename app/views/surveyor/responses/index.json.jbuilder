json.(@responses) do |response|
  json.ssrid            response.try(:respondable).try(:ssr_id) || 'N/A'
  json.short_title      response.try(:respondable).try(:protocol).try(:short_title) || 'N/A'
  json.primary_pi       response.try(:respondable).try(:protocol).try(:primary_principal_investigator).try(:full_name) || 'N/A'
  json.title            response.survey.title
  json.complete         complete_display(response)
  json.completion_date  response.completed? ? format_date(response.created_at) : ''
  json.actions          response_options(response)
end
