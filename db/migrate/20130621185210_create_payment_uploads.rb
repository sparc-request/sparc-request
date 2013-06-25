class CreatePaymentUploads < ActiveRecord::Migration
  def up
    create_table :payment_uploads do |t|
      t.references :payment
      t.timestamps
    end
    add_attachment :payment_uploads, :file
    add_index :payment_uploads, :payment_id
  end

  def down
    drop_table :payment_uploads
  end
end
