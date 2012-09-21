class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.integer :service_request_id
      t.integer :identity_id
      t.string :token
      
      t.timestamps
    end

    add_index :tokens, :service_request_id
  end
end
