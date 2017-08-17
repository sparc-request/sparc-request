class IncreaseSurveyDescriptionLengths < ActiveRecord::Migration[4.2][5.0]
  def up
    change_column :surveys, :description, :text
    change_column :sections, :description, :text
    change_column :questions, :description, :text
  end

  def down
    change_column :surveys, :description, :string
    change_column :sections, :description, :string
    change_column :questions, :description, :string
  end
end
