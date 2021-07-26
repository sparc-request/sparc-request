class ChangeAllResearchBillingToBillingType < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :default_billing_type, :string, default: "r"

    Protocol.where(all_research_billing: true).update_all(default_billing_type: "r")
    Protocol.where(all_research_billing: false).update_all(default_billing_type: "t")

    remove_column :protocols, :all_research_billing
  end
end
