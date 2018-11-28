class RemoveIdentityApprovedDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_null :identities, :approved, true
    change_column_default :identities, :approved, nil
  end
end
