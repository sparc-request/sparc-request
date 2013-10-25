class AddAppointmentIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :appointment_id, :integer
  end
end
