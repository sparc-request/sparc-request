# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class CreateStudyTypeQuestions < ActiveRecord::Migration
  def change
    create_table :study_type_questions do |t|
      t.integer :order
      t.string :question
      t.string :friendly_id

      t.timestamps
    end

    friendly_ids = ['higher_level_of_privacy', 'certificate_of_conf', 'access_study_info', 'epic_inbasket', 'research_active', 'restrict_sending']

    STUDY_TYPE_QUESTIONS.each_with_index do |stq, index|
      StudyTypeQuestion.create(order: index + 1, question: stq, friendly_id: friendly_ids[index])
    end
  end
end
