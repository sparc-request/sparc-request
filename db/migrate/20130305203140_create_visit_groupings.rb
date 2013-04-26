class CreateVisitGroupings < ActiveRecord::Migration
  def change
    create_table :visit_groupings do |t|
      t.integer :arm_id
      t.integer :line_item_id
      t.integer :subject_count

      t.timestamps
    end
  end
end
