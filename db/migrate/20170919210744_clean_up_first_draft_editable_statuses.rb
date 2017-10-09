class CleanUpFirstDraftEditableStatuses < ActiveRecord::Migration[5.1]
  def change
    # first_draft was removed from EditableStatuses because it is not present in AVAILABLE_STATUSES
    EditableStatus.where(status: 'first_draft').destroy_all
  end
end
