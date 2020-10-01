class RenameEpicStudyRootSetting < ActiveRecord::Migration[5.2]
  def change
    if epic_study_root = Setting.find_by_key('epic_study_root')
      epic_study_root.update_attribute('key', 'epic_study_rsh_root')
    end
  end
end
