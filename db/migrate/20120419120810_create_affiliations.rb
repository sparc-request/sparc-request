class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations do |t|
      t.integer :protocol_id
      t.string  :name

      t.timestamps
    end

    add_index :affiliations, :protocol_id
  end
end
