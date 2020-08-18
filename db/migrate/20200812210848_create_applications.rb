class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications do |t|
      t.string      :name
      t.string      :description
      t.string      :domain
      t.text        :token_ciphertext

      t.timestamps
    end

    add_column  :applications, :created_by, :bigint, after: :created_at
    add_index   :applications, :created_by
  end
end
