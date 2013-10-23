class TransitionAppointmentCompletions < ActiveRecord::Migration
  def up
    drop_table :appointment_completions
    add_column :appointments, :completed_at, :date
  end

  def down
  end
end
