class AddProtocolRefToExternalOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_reference :external_organizations, :protocol, foreign_key: true
  end
end
