class CreateShortInteractions < ActiveRecord::Migration[4.2]
  def change
    create_table :short_interactions do |t|
      t.integer :identity_id
      t.string :name
      t.string :email
      t.string :institution
      t.integer :duration_in_minutes
      t.string :subject
      t.string :note

      t.timestamps
    end

      add_index :short_interactions, :identity_id
      
  end
end
