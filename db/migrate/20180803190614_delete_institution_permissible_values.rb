class DeleteInstitutionPermissibleValues < ActiveRecord::Migration[5.2]
  def change
    # update existing short interaction institution field
    ShortInteraction.all.each do |si|
      si.update_attribute(:institution, si.institution.titleize)
    end

    # delete permissible values 'institution' category
    institutions = PermissibleValue.where(category: 'institution')
    institutions.destroy_all if institutions
  end
end
