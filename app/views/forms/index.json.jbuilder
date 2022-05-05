json.(@forms) do |form, respondable|
  if respondable
    completed = respondable.form_completed?(form)

    json.srid         respondable.try(&:display_id)
    json.association  form.surveyable.try(:organization_hierarchy, true, false, true)
    json.title        form.title
    json.completed    form_completed_display(completed)
    json.actions      form_options(form, completed, respondable)
    if response = Response.where(survey: form, respondable: respondable).first
      json.by                response.identity.try(:full_name) || 'N/A'
      json.completion_date   format_date(response.created_at)
    end
  end
end
