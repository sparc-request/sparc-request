require 'open-uri'
require 'json'
require 'progress_bar'

def get_json(uri)
  # p uri
  return JSON.parse(open(uri).read())
end

service_requests = get_json("http://localhost:4567/obisentity/service_requests")

service_requests_by_obisid = { }
service_requests.each do |sr|
  id = sr['_id']
  service_requests_by_obisid[id] = sr
end

bar = ProgressBar.new(service_requests.count)

# Find identities that are referring to deleted sub service requests
service_requests.each do |service_request|
  id = service_request['_id']
  relationships = get_json("http://localhost:4567/obisentity/service_requests/#{id}/relationships")
  relationships.each do |relationship|
    if relationship['relationship_type'] == 'service_request_owner' then
      relid = relationship['_id']
      service_request_obisid = relationship['from']
      sub_service_request_id = relationship['attributes']['sub-service-request-id']

      found = false

      service_request['attributes']['sub_service_requests'].each do |ssr_id, sub_service_request|
        if sub_service_request_id == ssr_id then
          found = true
        end
      end

      if not found then
        puts "delete_relationship service_requests #{id} #{relid} # #{sub_service_request_id}"
      end
    end
  end

  bar.increment!
end

