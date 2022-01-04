json.(@overlords) do |overlord|
  json.name       overlord.last_name_first
  json.email      overlord.email
  json.action     overlord_action(overlord)
end
