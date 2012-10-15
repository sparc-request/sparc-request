class ChangeColumnNamesInPricingSetups < ActiveRecord::Migration
  def change
    change_table :pricing_setups do |t|
      t.rename :college_funding_source, :college_rate_type
      t.rename :federal_funding_source, :federal_rate_type
      t.string :foundation_rate_type
      t.rename :industry_funding_source, :industry_rate_type
      t.rename :investigator_funding_source, :investigator_rate_type
      t.rename :internal_funding_source, :internal_rate_type
    end
  end
end
