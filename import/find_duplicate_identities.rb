require 'open-uri'
require 'json'
# require 'progress_bar'
require 'pp'
require 'set'

def get_json(uri)
  # p uri
  return JSON.parse(open(uri).read())
end

identities = get_json("http://localhost:4567/obisentity/identities")
identities_by_email = Hash.new

# bar = ProgressBar.new(identities.count)

identities.each do |identity|
  id = identity['_id']
  email = identity['attributes']['email']
  identities_by_email[email] ||= [ ]
  identities_by_email[email] << identity
end

identities_by_email.each do |email, identities|
  if identities.length > 1 then
    to_delete = 0

    identities.each do |identity|
      id = identity['_id']
      relationships = get_json("http://localhost:4567/obisentity/identites/#{id}/relationships")
      if relationships.length == 0 then
        puts "delete_entity identities #{id} # #{email} #{identity['attributes']['uid']}"
        to_delete += 1
      end
    end

    if to_delete < identities.length - 1 then
      puts "WARNING: found duplicate identities with relationships"
      p identities
    end
  end
end

