class CreateQuestions < ActiveRecord::Migration
  def up
    create_table :questions do |t|
      t.string :to, :from
      t.text   :body
      t.timestamps
    end
  end

  def down
    drop_table :questions
  end
end
