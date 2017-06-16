class DropContactForms < ActiveRecord::Migration[5.1]
  def change
    drop_table :contact_forms
  end
end
