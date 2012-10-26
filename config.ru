# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

require 'ruby-prof'
if Rails.env.profile? then
  puts "Enabling profiling"
  Dir.mkdir 'profile' rescue Errno::EEXIST
  use Rack::RubyProf, :path => 'profile', :printers => { RubyProf::CallTreePrinter => 'calltree.out' }
end

run SparcRails::Application

