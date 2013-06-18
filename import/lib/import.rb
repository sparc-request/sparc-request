require 'pathname'
require 'active_record'
require 'active_support/core_ext/string/inflections'

# TODO: rails requires these by default.  is there any way for the
# import script to also require them by default?
require 'devise'
require 'devise/orm/active_record'
require 'grouped_validations'
require 'acts_as_list'
require 'paperclip'
require 'acts-as-taggable-on'

# TODO: these are required by application.rb.  is there any way to
# require them by default?
require 'bulk_creatable_list'
require 'entity'

# Wow what a hack.  I'm in a bad mood.  Sorry to whomever reads this code.
class <<Rails
  def root
    return Pathname.new("#{File.dirname(__FILE__)}/../..")
  end
end

require_relative '../../config/application'

Dir["#{File.dirname(__FILE__)}/../../config/initializers/*.rb"].each do |model_file|
  resource = "../../config/initializers/#{File.basename(model_file).gsub(/\.rb$/, '')}"
  require_relative resource
end

# Load all the model files
# TODO: rails "knows" what order to require all these files in.  how
# does it do that?
require 'models/organization'
require 'models/protocol'

Dir["#{File.dirname(__FILE__)}/../../app/models/*.rb"].each do |model_file|
  resource = "models/#{File.basename(model_file).gsub(/\.rb$/, '')}"
  require resource
end

# Load all the files required for the import
require 'import/models/json_serializable'
require 'import/models/relationship'
require 'import/models/parse_date'
require 'import/models/entity'
require 'import/models/organization'
require 'import/models/protocol'
Dir['./lib/import/models/*.rb'].each do |model_file|
  resource = "import/models/#{File.basename(model_file).gsub(/\.rb$/, '')}"
  require resource
end

require 'import/obis_entity'
require 'import/annotate'
require 'import/validation_disabler'

