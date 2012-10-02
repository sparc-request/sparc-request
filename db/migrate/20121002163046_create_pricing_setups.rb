class CreatePricingSetups < ActiveRecord::Migration
  def change
    create_table :pricing_setups do |t|
      t.integer :organization_id
      t.datetime :display_date
      t.datetime :effective_date
      t.boolean :charge_master
      t.decimal :federal, :precision => 5, :scale => 2
      t.decimal :corporate, :precision => 5, :scale => 2
      t.decimal :other, :precision => 5, :scale => 2
      t.decimal :member, :precision => 5, :scale => 2
      t.string :college_funding_source
      t.string :federal_funding_source
      t.string :industry_funding_source
      t.string :investigator_funding_source
      t.string :internal_funding_source
    end
  end
end
