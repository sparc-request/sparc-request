json.(@forms) do |form, respondable|
  completed = respondable.form_completed?(form)

  json.srid         respondable.try(&:display_id)
  json.association  form.surveyable.try(:organization_hierarchy, true, false, true)
  json.title        form.title
  json.completed    form_completed_display(form, completed)
  json.options      form_options(form, completed, respondable)
end
