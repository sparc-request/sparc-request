class CreateLookups < ActiveRecord::Migration
  def change
    create_table :lookups do |t|
      t.integer :new_id
      t.string :old_id
    end
  end
end
