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

pricing_setups = obisentity.get_all('pricing_setup')
pricing_maps = obisentity.get_all('pricing_maps')
json = [ pricing_setups, pricing_maps ].to_json

File.open('pricing.json', 'w') do |out|
  out.puts json
end

