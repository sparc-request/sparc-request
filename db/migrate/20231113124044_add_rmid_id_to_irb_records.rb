class AddRmidIdToIrbRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :irb_records, :rmid_id, :integer, after: :human_subjects_info_id
  end
end
