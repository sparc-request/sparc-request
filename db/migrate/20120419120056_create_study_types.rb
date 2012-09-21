class CreateStudyTypes < ActiveRecord::Migration
  def change
    create_table :study_types do |t|
      t.integer :protocol_id
      t.boolean :clinical_trials
      t.boolean :translational_science
      t.boolean :basic_science

      t.timestamps
    end

    add_index :study_types, :protocol_id
  end
end
