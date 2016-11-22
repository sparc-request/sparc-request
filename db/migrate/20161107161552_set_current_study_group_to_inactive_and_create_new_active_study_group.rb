class SetCurrentStudyGroupToInactiveAndCreateNewActiveStudyGroup < ActiveRecord::Migration
  def change
    StudyTypeQuestionGroup.update_all(active: false)
    StudyTypeQuestionGroup.create(active: true)
  end
end
