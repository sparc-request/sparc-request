class AddCompanyAndReasonToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :reason, :text
    add_column :identities, :company, :string
  end
end
