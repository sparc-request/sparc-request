class AddValidateContentToItemOptions < ActiveRecord::Migration
  def change
    add_column :item_options, :validate_content, :boolean, after: :content
  end
end
