json.total @epic_queues.count
json.rows do
  json.(@epic_queues.limit(params[:limit]).offset(params[:offset])) do |eq|
    json.protocol_id  eq.protocol_id
    json.protocol     format_protocol(eq.protocol)
    json.pis          format_pis(eq.protocol)
    json.date         format_epic_queue_date(eq.protocol)
    json.status       format_status(eq.protocol)
    json.delete       epic_queue_delete_button(eq)
    json.created_at   format_epic_queue_created_at(eq)
    json.name         eq.identity.full_name
    json.send         epic_queue_send_button(eq)
  end
end
