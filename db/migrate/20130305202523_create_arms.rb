class CreateArms < ActiveRecord::Migration
  def change
    create_table :arms do |t|

      t.timestamps
    end
  end
end
