class CreateStudyTypes < ActiveRecord::Migration
  def change
    create_table :study_types do |t|
      t.integer :protocol_id
      t.string  :name

      t.timestamps
    end

    add_index :study_types, :protocol_id
  end
end
