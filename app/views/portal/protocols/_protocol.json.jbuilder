json.(protocol)

json.id protocol.id
json.title protocol.short_title
json.pis protocol.principal_investigators.map(&:full_name)
json.requests requests_display(protocol)
json.archive protocol.archived
