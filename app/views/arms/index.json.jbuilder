json.(@arms) do |arm|
  json.name          arm.name
  json.subject_count arm.subject_count
  json.visit_count   arm.visit_count
  json.edit          arms_edit_button(arm, @arms_editable)
  json.delete        arms_delete_button(arm, @arms_editable, @arm_count)
end