class RemoveInstitutionPermissibleValues < ActiveRecord::Migration[5.2]
  def change
    PermissibleValue.where(category: 'institution').destroy_all
  end
end
