class SetCurrentStudyGroupToInactiveAndCreateNewActiveStudyGroup < ActiveRecord::Migration[5.1]
  def change
    StudyTypeQuestionGroup.update_all(active: false)
    StudyTypeQuestionGroup.create(active: true)
  end
end
