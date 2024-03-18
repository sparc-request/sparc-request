# Rails.autoloaders.main.do_not_eager_load("#{Rails.root}/app/api/v1")
# Rails.autoloaders.main.do_not_eager_load("#{Rails.root}/app/api/sparccwf/v1/entities.rb")
# Rails.autoloaders.main.do_not_eager_load("#{Rails.root}/app/api/sparccwf/v1/entities")
# Rails.autoloaders.main.do_not_eager_load("#{Rails.root}/app/api/sparccwf/v1/helpers_v1.rb")
# Rails.autoloaders.main.do_not_eager_load("#{Rails.root}/app/api/sparccwf/v1/shared_params_v1.rb")
# Rails.autoloaders.main.do_not_eager_load("#{Rails.root}/app/api/sparccwf/v1/validators_v1.rb")
# ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/lib")

Rails.autoloaders.main.ignore(
  "app/api/v1",
  "app/lib/bulk_creatable.rb",
  "app/lib/bulk_creatable_list.rb",
  "app/lib/initial_cm_creation.rb",
  "app/lib/reports.rb",
  "app/lib/reports"
)