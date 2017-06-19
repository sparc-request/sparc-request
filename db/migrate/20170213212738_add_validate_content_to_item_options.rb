class AddValidateContentToItemOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :item_options, :validate_content, :boolean, after: :content
  end
end
