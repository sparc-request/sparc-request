# require the base class
require 'reporting_module'

# require subclasses
Dir[Rails.root.join("lib/canned_reports/*.rb")].each {|f| require f}
