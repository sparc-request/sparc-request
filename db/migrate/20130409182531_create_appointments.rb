class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.belongs_to :calendar
      t.datetime :completed_at

      t.timestamps
    end
  end
end
