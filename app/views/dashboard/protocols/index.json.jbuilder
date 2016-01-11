json.total @total_protocols
json.rows do
  json.partial! 'protocol', collection: @protocols, as: :protocol
end
