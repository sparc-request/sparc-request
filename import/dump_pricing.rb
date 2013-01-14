require 'open-uri'
require 'json'
require 'fileutils'
require 'ostruct'
require 'pstore'
require 'progress_bar'
require 'optparse'

require 'active_support/core_ext/object/blank'

require 'import'
require 'import/validate'
require 'import/compare'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',   
    :database => 'sparc_development',  
    :username => 'sparc',
    :password => 'sparc'
) 

pricing_setups = PricingSetup.all.to_json(:jsontype => :pricing)
pricing_maps = PricingMap.all.to_json(:jsontype => :pricing)

File.open('pricing_setups.json', 'w') do |out|
  out.puts pricing_setups
end

File.open('pricing_maps.json', 'w') do |out|
  out.puts pricing_maps
end
