# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
desc "Print API routes"
task api_routes: :environment do

  puts 'v1/SPARCCWF'

  SPARCCWF::V1::APIv1.routes.each do |route|
    puts route
  end
end
