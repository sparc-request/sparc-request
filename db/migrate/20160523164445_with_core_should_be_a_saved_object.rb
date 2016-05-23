class WithCoreShouldBeASavedObject < ActiveRecord::Migration
  def change
    change_column :protocol_filters, :with_core, :string
  end
end
