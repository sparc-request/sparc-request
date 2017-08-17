class AddToAndFromIndexToMessage < ActiveRecord::Migration[5.1]
  def change
    add_index :messages, :to
    add_index :messages, :from
  end
end
