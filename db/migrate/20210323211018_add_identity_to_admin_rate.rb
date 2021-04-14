class AddIdentityToAdminRate < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_rates, :identity_id, :integer

    puts "Populated Identity Column for Existing Admin Rates"
    bar = ProgressBar.new(AdminRate.count)

    AdminRate.find_each do |admin_rate|
      audit = AuditRecovery.where(auditable_id: admin_rate.id, auditable_type: "AdminRate", action: "create").first
      admin_rate.update_attributes(identity_id: audit.try(:user_id))
      bar.increment!
    end
  end
end
