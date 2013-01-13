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

obisentity = ObisEntity.new

pricing_setups = JSON.parse(obisentity.get_all('pricing_setup'))
pricing_maps = JSON.parse(obisentity.get_all('pricing_maps'))

File.open('pricing_setups.json', 'w') do |out|
  out.puts pricing_setups.to_json
end

File.open('pricing_maps.json', 'w') do |out|
  out.puts pricing_maps.to_json
end
