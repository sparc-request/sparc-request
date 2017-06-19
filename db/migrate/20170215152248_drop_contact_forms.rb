class DropContactForms < ActiveRecord::Migration[4.2]
  def change
    drop_table :contact_forms
  end
end
