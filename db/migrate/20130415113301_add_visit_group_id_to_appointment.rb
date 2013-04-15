class AddVisitGroupIdToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :visit_group_id, :integer
  end
end
