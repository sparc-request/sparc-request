class DefaultUnfundedRateToFederal < ActiveRecord::Migration
  def change
    pricing_setups = PricingSetup.all

    pricing_setups.each do |setup|
      unless setup.unfunded_rate_type
        setup.update_attributes(unfunded_rate_type: 'federal')
      end
    end
  end
end
