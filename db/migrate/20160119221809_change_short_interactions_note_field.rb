class ChangeShortInteractionsNoteField < ActiveRecord::Migration[4.2]
  def up
    change_column :short_interactions, :note, :text
  end

  def down
    change_column :short_interactions, :note, :string
  end
end
