class CreateSubmissionEmails < ActiveRecord::Migration
  def change
    create_table :submission_emails do |t|
      t.integer :organization_id
      t.string :email

      t.timestamps
    end

    add_index :submission_emails, :organization_id
  end
end
