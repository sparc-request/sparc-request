class AddValidateContentToItemOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :item_options, :validate_content, :boolean, after: :content
  end
end
