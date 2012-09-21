class CreateVertebrateAnimals < ActiveRecord::Migration
  def change
    create_table :vertebrate_animals do |t|
      t.integer :protocol_id
      t.string :iacuc_number
      t.string :name_of_iacuc
      t.datetime :iacuc_approval_date
      t.datetime :iacuc_expiration_date

      t.timestamps
    end

    add_index :vertebrate_animals, :protocol_id
  end
end
