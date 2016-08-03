# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddUnfundedToPricingSetups < ActiveRecord::Migration
  def change
    add_column :pricing_setups, :unfunded_rate_type, :string
  end
end
