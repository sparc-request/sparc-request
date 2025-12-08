class AddUseAdminServicesSetting < ActiveRecord::Migration[7.0]
  def up
    Setting.create!(
      key: "use_admin_services",
      value: "false",
      data_type: "boolean",
      friendly_name: "Use Admin Services",
      description: "Allows service providers to add services for administrative purposes that are not visible to the research teams"
    )
  end

  def down
    Setting.find_by(key: "use_admin_services")&.destroy
  end
end
