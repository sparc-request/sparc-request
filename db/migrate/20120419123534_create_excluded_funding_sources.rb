class CreateExcludedFundingSources < ActiveRecord::Migration
  def change
    create_table :excluded_funding_sources do |t|
      t.integer :subsidy_map_id
      t.string :funding_source

      t.timestamps
    end

    add_index :excluded_funding_sources, :subsidy_map_id
  end
end
