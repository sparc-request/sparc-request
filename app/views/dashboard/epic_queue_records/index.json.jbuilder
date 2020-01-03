# If we've pushed or deleted the last record on a page and refreshed
# then we need to show the previous page by subtracting the limit
# from the offset
if @epic_queue_records.count > 0 && @epic_queue_records.count <= params[:offset].to_i
  params[:offset] = (params[:offset].to_i - params[:limit].to_i).to_s
end

json.total @epic_queue_records.count
json.rows do
  json.(@epic_queue_records.limit(params[:limit]).offset(params[:offset])) do |eqr|
    json.protocol_id  eqr.protocol_id
    json.protocol     format_protocol(eqr.protocol)
    json.notes        notes_button(eqr, protocol_id: eqr.protocol.id)
    json.pis          format_pis(eqr.protocol)
    json.date         format_epic_queue_created_at(eqr)
    json.status       eqr.status.capitalize
    json.type         eqr.origin.try(:titleize)
    json.by           eqr.try(:identity).try(:full_name)
  end
end
