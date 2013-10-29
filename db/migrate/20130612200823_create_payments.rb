class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :sub_service_request_id
      t.date    :date_submitted
      t.decimal :amount_invoiced, :precision => 12, :scale => 4
      t.decimal :amount_received, :precision => 12, :scale => 4
      t.date    :date_received
      t.string  :payment_method
      t.text    :details

      t.timestamps
    end

    add_index :payments, :sub_service_request_id
  end
end
