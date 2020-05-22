class AddAllowCreditToSuperUsers < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    add_column :super_users, :allow_credit, :boolean
  end
end
