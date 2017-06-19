class AddLineItemIdToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_reference :submissions, :line_item, index: true, foreign_key: true, after: :protocol_id
  end
end
