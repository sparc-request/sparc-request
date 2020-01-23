class AddAllowCreditToSuperUsers < ActiveRecord::Migration[5.2]
    def change
    add_column :super_users, :allow_credit, :boolean
  end
end
