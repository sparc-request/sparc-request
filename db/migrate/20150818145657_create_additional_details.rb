class CreateAdditionalDetails < ActiveRecord::Migration
  def change
    create_table :additional_details do |t|
      t.string :name
      t.string :description
      t.string :form_definition_json
      t.date :effective_date
      t.boolean :approved
      t.references :service

      t.timestamps
    end
    add_index :additional_details, :service_id
  end
end
