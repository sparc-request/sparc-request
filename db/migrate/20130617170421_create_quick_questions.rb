class CreateQuickQuestions < ActiveRecord::Migration
  def change
    create_table :quick_questions do |t|
      t.string :to
      t.string :from
      t.text :body

      t.timestamps
    end
  end
end
