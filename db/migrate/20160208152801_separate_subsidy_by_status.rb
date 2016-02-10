class SeparateSubsidyByStatus < ActiveRecord::Migration

  def self.up
    add_column :subsidies, :total_at_approval, :integer
    add_column :subsidies, :status, :string, default: "Pending"
    add_column :subsidies, :approved_by, :integer
    add_column :subsidies, :approved_at, :datetime

    Subsidy.all.each do |s|
      s.update_column(:status, "Approved")
      s.update_column(:approved_at, s.attributes["updated_at"])
      s.update_column(:total_at_approval, get_total_at_approval(s))
    end
  end

  def self.down
    remove_column :subsidies, :total_at_approval, :integer
    remove_column :subsidies, :status, :string
    remove_column :subsidies, :approved_by, :integer
    remove_column :subsidies, :approved_at, :datetime
  end

  private

  def get_total_at_approval subsidy
    begin
      subsidy.sub_service_request.direct_cost_total
    rescue
      percentage    = subsidy.stored_percent_subsidy / 100.00
      contribution  = subsidy.pi_contribution / 100.00
      total         = ( contribution / (1 - percentage) ) * 100
      return total
    end
  end

end
