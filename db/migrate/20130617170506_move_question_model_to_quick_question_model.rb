class MoveQuestionModelToQuickQuestionModel < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute("insert into quick_questions select * from questions")
  end

  def down
  end
end
