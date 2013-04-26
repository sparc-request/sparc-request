class CreateArms < ActiveRecord::Migration
  def change
    create_table :arms do |t|
      t.string :name
      t.integer :visit_count
      t.belongs_to :service_request
      t.timestamps
    end
  end
end
