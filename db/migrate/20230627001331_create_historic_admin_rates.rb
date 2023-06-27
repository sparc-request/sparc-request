class CreateHistoricAdminRates < ActiveRecord::Migration[5.2]
  def up
    create_table :historic_admin_rates do |t|
      t.references  :line_item
      t.references  :identity
      t.integer     :admin_cost
      t.datetime    :original_date

      t.timestamps
    end
    failed_historic_rates = []
    admin_rate_groups = AdminRate.all.group_by(&:line_item_id)
    bar = ProgressBar.new(admin_rate_groups.size)
    admin_rate_groups.each do |line_item_id, admin_rates|
      (bar.increment! && next) if admin_rates.size < 2

      admin_rates.sort_by!(&:created_at)
      current_admin_rate = admin_rates.last
      old_admin_rates = admin_rates.without(current_admin_rate)

      old_admin_rates.each do |old_rate|
        if HistoricAdminRate.create(
          line_item_id: line_item_id,
          admin_cost: old_rate.admin_cost,
          identity_id: old_rate.identity_id,
          original_date: old_rate.created_at
        )
          old_rate.destroy
        else
          failed_historic_rates << old_rate
        end
      end

      bar.increment!
    end

    if failed_historic_rates.any?
      puts "ID's of admin rates that could not be converted:"
      puts failed_historic_rates.map(&:id)
    else
      puts "All historic admin rates migrated without error"
    end
  end

  def down
    HistoricAdminRate.find_each do |historic_rate|
      AdminRate.create(
        line_item_id: historic_rate.line_item_id,
        identity_id: historic_rate.identity_id,
        admin_cost: historic_rate.admin_cost,
        created_at: historic_rate.original_date
      )
    end

    drop_table :historic_admin_rates
  end
end
