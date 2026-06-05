class AddUseAdminServicesSetting < ActiveRecord::Migration[7.0]
  def up
    setting = Setting.find_or_initialize_by(key: "use_admin_services")
    setting.value = "false",
    setting.data_type = "boolean",
    setting.friendly_name = "Use Admin Services",
    setting.description = "Allows service providers to add services for administrative purposes that are not visible to the research teams"
    setting.save(validate: false)
  end

  def down
    Setting.find_by(key: "use_admin_services")&.destroy
  end
end
