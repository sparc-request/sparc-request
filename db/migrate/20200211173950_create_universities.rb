class CreateUniversities < ActiveRecord::Migration[6.0]
  using(:master)

  def change
    create_table :universities do |t|
      t.string :key
      t.string :name
    end
  end
end
