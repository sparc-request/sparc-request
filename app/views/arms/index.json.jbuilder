json.(@arms) do |arm|
  json.name          arm_name_helper(arm)
  json.subject_count arm.subject_count
  json.visit_count   arm.visit_count
  json.actions       arms_actions(arm, @arms_editable, @arm_count)
end
