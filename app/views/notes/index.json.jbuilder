json.(@notes) do |note|
  json.user     note.identity.full_name
  json.date     format_date(note.created_at)
  json.note     note.body
  json.actions  note_actions(note)
end
