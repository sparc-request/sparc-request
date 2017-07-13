class AddRmidValidatedToProtocols < ActiveRecord::Migration[5.0]
  def change
    add_column :protocols, :rmid_validated, :boolean, default: false
  end
end
