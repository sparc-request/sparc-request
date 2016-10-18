class AddLineItemIdToSubmissions < ActiveRecord::Migration
  def change
    add_reference :submissions, :line_item, index: true, foreign_key: true, after: :protocol_id
  end
end
