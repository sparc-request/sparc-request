# If we've pushed or deleted the last record on a page and refreshed
# then we need to show the previous page by subtracting the limit
# from the offset
if @epic_queues.count > 0 && @epic_queues.count <= params[:offset].to_i
  params[:offset] = (params[:offset].to_i - params[:limit].to_i).to_s
end

json.total @epic_queues.count
json.rows do
  json.(@epic_queues.limit(params[:limit]).offset(params[:offset])) do |eq|
    json.protocol     format_protocol(eq.protocol)
    json.pis          format_pis(eq.protocol)
    json.date         format_epic_queue_date(eq.protocol)
    json.status       format_status(eq.protocol)
    json.created_at   format_epic_queue_created_at(eq)
    json.name         eq.identity.full_name
    json.actions      epic_queue_actions(eq)
  end
end
