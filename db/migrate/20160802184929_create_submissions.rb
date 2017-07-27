class CreateSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :submissions do |t|
      t.references :service, index: true, foreign_key: true
      t.references :identity, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
