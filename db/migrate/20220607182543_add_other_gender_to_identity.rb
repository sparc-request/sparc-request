class AddOtherGenderToIdentity < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :gender_other, :string
  end
end
