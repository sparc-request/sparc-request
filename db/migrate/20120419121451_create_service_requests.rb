class CreateServiceRequests < ActiveRecord::Migration
  def change
    create_table :service_requests do |t|
      t.integer :protocol_id
      t.string :obisid
      t.string :status
      t.integer :service_requester_id
      t.text :notes
      t.boolean :approved
      t.datetime :start_date
      t.datetime :end_date
      t.integer :visit_count
      t.integer :subject_count
      t.datetime :consult_arranged_date
      t.datetime :pppv_complete_date
      t.datetime :pppv_in_process_date
      t.datetime :requester_contacted_date
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :service_requests, :protocol_id
    add_index :service_requests, :obisid
    add_index :service_requests, :status
    add_index :service_requests, :service_requester_id
  end
end
