class CreateAppointmentCompletions < ActiveRecord::Migration
  def change
    create_table :appointment_completions do |t|
      t.datetime :completed_date
      t.references :appointment
      t.references :organization

      t.timestamps
    end

    remove_column :appointments, :completed_at

    add_index :appointment_completions, :appointment_id
    add_index :appointment_completions, :organization_id

    Appointment.all.each do |app|
      app.create_appointment_completions
    end
    
  end
end
