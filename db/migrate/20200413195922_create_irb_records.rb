class CreateIrbRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :irb_records do |t|
      t.references  :human_subjects_info
      t.string      :pro_number
      t.string      :irb_of_record
      t.string      :submission_type
      t.date        :initial_irb_approval_date
      t.date        :irb_approval_date
      t.date        :irb_expiration_date
      t.boolean     :approval_pending

      t.timestamps
    end

    IrbRecord.reset_column_information

    HumanSubjectsInfo.all.each do |hsi|
      irb = hsi.irb_records.new

      irb.assign_attributes(hsi.attributes.except(
        'id', 'protocol_id', 'nct_number', 'deleted_at'
      ))

      irb.save
    end

    remove_column :human_subjects_info, :pro_number
    remove_column :human_subjects_info, :irb_of_record
    remove_column :human_subjects_info, :submission_type
    remove_column :human_subjects_info, :initial_irb_approval_date
    remove_column :human_subjects_info, :irb_approval_date
    remove_column :human_subjects_info, :irb_expiration_date
    remove_column :human_subjects_info, :approval_pending
  end
end
