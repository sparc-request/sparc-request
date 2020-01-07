json.(@arms) do |arm|
  json.name arm.name
  json.subject_count arm.subject_count
  json.visit_count arm.visit_count
end