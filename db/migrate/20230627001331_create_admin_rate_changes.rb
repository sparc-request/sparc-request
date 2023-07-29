class CreateAdminRateChanges < ActiveRecord::Migration[5.2]
  def up
    create_table :admin_rate_changes do |t|
      t.references  :line_item
      t.references  :identity
      t.integer     :admin_cost
      t.boolean     :cost_reset, default: false
      t.datetime    :date_of_change

      t.timestamps
    end
    failed_rate_changes = []
    admin_rate_groups = AdminRate.all.group_by(&:line_item_id)
    bar = ProgressBar.new(admin_rate_groups.size)
    admin_rate_groups.each do |line_item_id, admin_rates|
      admin_rates.sort_by!(&:created_at)
      current_admin_rate = admin_rates.last

      admin_rates.each do |admin_rate|
        if AdminRateChange.create(
          line_item_id: line_item_id,
          admin_cost: admin_rate.admin_cost,
          identity_id: admin_rate.identity_id,
          date_of_change: admin_rate.created_at
        )
          admin_rate.destroy if admin_rate != current_admin_rate
        else
          failed_rate_changes << admin_rate
        end
      end

      bar.increment!
    end

    if failed_rate_changes.any?
      puts "ID's of admin rates that could not be converted:"
      puts failed_rate_changes.map(&:id)
    else
      puts "All admin rate changes migrated without error"
    end
  end

  def down
    AdminRateChange.where(cost_reset: false).find_each do |rate_change|
      AdminRate.create(
        line_item_id: rate_change.line_item_id,
        identity_id: rate_change.identity_id,
        admin_cost: rate_change.admin_cost,
        created_at: rate_change.date_of_change
      )
    end

    drop_table :admin_rate_changes
  end
end
