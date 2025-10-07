class UpdateServicesIsAdministrativeFromNilToFalse < ActiveRecord::Migration[7.0]
  def change
    Service.where(is_administrative: nil).update_all(is_administrative: false)
  end
end
