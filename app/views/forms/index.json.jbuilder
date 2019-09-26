json.(@forms) do |form, respondable|
  if respondable
    completed = respondable.form_completed?(form)

    json.srid         respondable.try(&:display_id)
    json.association  form.surveyable.try(:organization_hierarchy, true, false, true)
    json.title        form.title
    json.completed    form_completed_display(completed)
    json.actions      form_options(form, completed, respondable)
  end
end
