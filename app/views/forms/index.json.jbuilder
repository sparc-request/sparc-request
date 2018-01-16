json.(@forms) do |form|
  completed = @service_request.form_completed?(form)
  respondable = @service_request.ssr_with_form(form)

  json.association  form.surveyable.try(:organization_hierarchy, true, false, true)
  json.title        form.title
  json.completed    form_completed_display(form, completed)
  json.options      form_options(form, completed, respondable)
end
