class AddIndexesToProceduresAndAppointments < ActiveRecord::Migration
  def change
  	add_index :procedures, :appointment_id
  	add_index :procedures, :visit_id
  	add_index :procedures, :line_item_id
  	add_index :appointments, :visit_group_id
  	add_index :appointments, :calendar_id
  end
end
