# require the base class
$canned_reports = []
require 'reporting_module'

# require subclasses
Dir[Rails.root.join("app/reports/*.rb")].each {|f| require f}
