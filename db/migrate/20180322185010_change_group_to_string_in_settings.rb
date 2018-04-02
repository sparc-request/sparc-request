class ChangeGroupToStringInSettings < ActiveRecord::Migration[5.1]
  def change
    change_column :settings, :group, :string
    Setting.reset_column_information
  end
end
