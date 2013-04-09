class CreateProcedures < ActiveRecord::Migration
  def change
    create_table :procedures do |t|
      t.belongs_to :appointment
      t.belongs_to :visit
      t.belongs_to :service
      t.integer :status
      t.boolean :to_be_done

      t.timestamps
    end
  end
end
