class CreateProcedures < ActiveRecord::Migration
  def change
    create_table :procedures do |t|
      t.belongs_to :appointment
      t.belongs_to :visit
      t.belongs_to :service
      t.boolean :completed
      t.boolean :required

      t.timestamps
    end
  end
end
