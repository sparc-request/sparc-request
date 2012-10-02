class AddOtherFundingSourceFields < ActiveRecord::Migration
  def up
    add_column :protocols, :potential_funding_source_other, :string
    add_column :protocols, :funding_source_other, :string
  end

  def down
    remove_column :protocols, :funding_source_other
    remove_column :protocols, :potential_funding_source_other
  end
end
