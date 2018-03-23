class ChangeGroupToStringInSettings < ActiveRecord::Migration[5.1]
  def change
    change_column :settings, :group, :string
  end
end
