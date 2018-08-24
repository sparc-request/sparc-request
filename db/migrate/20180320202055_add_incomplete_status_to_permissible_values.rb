class AddIncompleteStatusToPermissibleValues < ActiveRecord::Migration[5.1]
  def change
    #### Adding Incomplete status  
    status = PermissibleValue.create(
      key:           'incomplete',
      value:         'Incomplete',
      category:       'status',
      default:       0,
      sort_order:    25
    )

    Organization.all.each do |org|
      EditableStatus.create(organization_id: org.id, status: status.key)
      AvailableStatus.create(organization_id: org.id, status: status.key)
    end
  end
end
