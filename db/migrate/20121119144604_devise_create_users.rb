class DeviseCreateUsers < ActiveRecord::Migration
  def change
      ## Database authenticatable
      # add_column :identities, :email, :string, :null => false, :default => ""
      add_column :identities, :encrypted_password, :string, :null => false, :default => ""

      ## Recoverable
      add_column :identities, :reset_password_token, :string
      add_column :identities, :reset_password_sent_at, :datetime

      ## Rememberable
      add_column :identities, :remember_created_at, :datetime

      ## Trackable
      add_column :identities, :sign_in_count, :integer, :default => 0
      add_column :identities, :current_sign_in_at, :datetime
      add_column :identities, :last_sign_in_at, :datetime
      add_column :identities, :current_sign_in_ip, :string
      add_column :identities, :last_sign_in_ip, :string

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      # t.string :authentication_token

    #add_index :identities, :email,                :unique => true
    add_index :identities, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end
end
