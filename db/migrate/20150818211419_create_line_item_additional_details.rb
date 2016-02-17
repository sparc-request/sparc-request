class CreateLineItemAdditionalDetails < ActiveRecord::Migration
  def change
    create_table :line_item_additional_details do |t|
      t.text :form_data_json
      t.references :line_item
      t.references :additional_detail

      t.timestamps
    end
    add_index :line_item_additional_details, :line_item_id
    add_index :line_item_additional_details, :additional_detail_id
  end
end
