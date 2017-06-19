class SetCurrentStudyGroupToInactiveAndCreateNewActiveStudyGroup < ActiveRecord::Migration[4.2]
  def change
    StudyTypeQuestionGroup.update_all(active: false)
    StudyTypeQuestionGroup.create(active: true)
  end
end
