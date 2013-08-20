class MoveQuestionModelToQuickQuestionModel < ActiveRecord::Migration
  def up
    # populate quick_questions with questions
    ActiveRecord::Base.connection.execute("insert into quick_questions select * from questions")

    # check that counts are the same between questions and quick_questions
    questions_count = ActiveRecord::Base.connection.select("select count(*) as count from questions").first["count"]
    quick_questions_count = ActiveRecord::Base.connection.select("select count(*) as count from quick_questions").first["count"]

    if questions_count == quick_questions_count
      ActiveRecord::Base.connection.execute("drop table questions")
    else
      raise "Questions count not equal to quick questions count, copy failed"
    end
  end

  def down
  end
end
