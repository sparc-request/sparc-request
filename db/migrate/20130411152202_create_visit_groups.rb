class CreateVisitGroups < ActiveRecord::Migration
  def change
    create_table :visit_groups do |t|
      t.string :name
      t.references :arm

      t.timestamps
    end
    add_column :visits, :visit_group_id, :integer
    add_index :visit_groups, :arm_id
  end
end
