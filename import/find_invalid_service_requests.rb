require 'open-uri'
require 'json'
require 'progress_bar'

def get_json(uri)
  # p uri
  return JSON.parse(open(uri).read())
end

service_requests = get_json("http://localhost:4567/obisentity/service_requests")

bar = ProgressBar.new(service_requests.count)

# Find identies that are referring to deleted sub service requests
service_requests.each do |service_request|
  id = service_request['_id']
  ssrs = service_request['attributes']['sub_service_requests']
  line_items = service_request['attributes']['line_items']
  if ssrs.length == 0 and line_items.length == 0 then
    puts "delete_entity service_requests #{id} # no line items and no sub service requests"
  end

  bar.increment!
end

