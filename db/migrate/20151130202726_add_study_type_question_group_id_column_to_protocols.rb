# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddStudyTypeQuestionGroupIdColumnToProtocols < ActiveRecord::Migration
  def up
    add_column :protocols, :study_type_question_group_id, :integer
  end
end
