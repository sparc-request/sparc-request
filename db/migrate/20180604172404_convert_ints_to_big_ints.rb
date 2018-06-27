class ConvertIntsToBigInts < ActiveRecord::Migration[5.2]
  def change
    change_column :protocols, :initial_amount, :bigint
    change_column :protocols, :initial_amount_clinical_services, :bigint
    change_column :protocols, :negotiated_amount, :bigint
    change_column :protocols, :negotiated_amount_clinical_services, :bigint
  end
end
