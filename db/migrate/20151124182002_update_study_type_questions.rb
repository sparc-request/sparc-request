class UpdateStudyTypeQuestions < ActiveRecord::Migration
  def change
  	drop_table :study_type_questions 

    create_table :study_type_questions do |t|
      t.integer :order
      t.string :question
      t.string :friendly_id

      t.timestamps
    end

    friendly_ids = ['certificate_of_conf', 'higher_level_of_privacy', 'access_study_info', 'epic_inbasket', 'research_active', 'restrict_sending']

    STUDY_TYPE_QUESTIONS.each_with_index do |stq, index|
      StudyTypeQuestion.create(order: index + 1, question: stq, friendly_id: friendly_ids[index])
    end
  end
end