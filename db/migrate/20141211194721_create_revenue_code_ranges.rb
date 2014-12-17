class CreateRevenueCodeRanges < ActiveRecord::Migration
  def change
    create_table :revenue_code_ranges do |t|
      t.integer :from
      t.integer :to
      t.float :percentage
      t.integer :applied_org_id
      t.string :vendor
      t.integer :version

      t.timestamps
    end
  end
end
