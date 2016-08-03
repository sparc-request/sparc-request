# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class CreateStudyTypeQuestionGroups < ActiveRecord::Migration
  def up
    create_table :study_type_question_groups do |t|
      t.boolean :active, default: false

      t.timestamps
    end
  end
  def down
  	drop_table :study_type_question_groups
  end
end
