# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

require 'ruby-prof'
if Rails.env.profile? then
  puts "Enabling profiling"
  Dir.mkdir 'profile' rescue Errno::EEXIST
  use Rack::RubyProf, :path => 'profile', :printers => { RubyProf::CallTreePrinter => 'calltree.out' }
end

if Rails.env.development? then
  # puts "Removing filters from backtrace cleaner"
  # Rails.backtrace_cleaner.remove_filters!
end

run SparcRails::Application

