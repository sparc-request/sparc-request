class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :service_request_id
      t.integer :sub_service_request_id
      t.integer :service_id
      t.string :ssr_id
      t.boolean :is_one_time_fee
      t.boolean :optional
      t.integer :quantity
      t.integer :subject_count
      t.datetime :complete_date
      t.datetime :in_process_date

      t.timestamps
    end

    add_index :line_items, :service_request_id
  end
end
