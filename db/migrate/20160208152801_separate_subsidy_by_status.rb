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

    remove_column :subsidies, :stored_percent_subsidy, :float
  end

  def self.down
    add_column :subsidies, :stored_percent_subsidy, :float

    Subsidy.all.each do |s|
      s.update_column(:stored_percent_subsidy, get_stored_percent(s))
    end

    remove_column :subsidies, :total_at_approval, :integer
    remove_column :subsidies, :status, :string
    remove_column :subsidies, :approved_by, :integer
    remove_column :subsidies, :approved_at, :datetime
  end

  private

  def get_total_at_approval subsidy
    begin
      total = subsidy.sub_service_request.direct_cost_total
    rescue
      total = calc_total_via_percent(subsidy)
    end

    if subsidy.pi_contribution
      total = subsidy.pi_contribution if subsidy.pi_contribution > total
    end

    return total || 0
  end

  def calc_total_via_percent subsidy
    percentage    = subsidy.stored_percent_subsidy / 100.0
    total         = ( subsidy.pi_contribution / (1 - percentage) )
    return total
  end

  def get_stored_percent subsidy
    contribution = subsidy.pi_contribution / 100.0
    total = (subsidy.total_at_approval || subsidy.sub_service_request.direct_cost_total) / 100.0
    percent = total > 0 ? ((total - contribution) / total) * 100.0 : 0

    return percent.round(2)
  end

end
