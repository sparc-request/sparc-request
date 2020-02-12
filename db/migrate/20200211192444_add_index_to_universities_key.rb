class AddIndexToUniversitiesKey < ActiveRecord::Migration[6.0]
  using(:master)

  def change
    add_index :universities, :key
  end
end
