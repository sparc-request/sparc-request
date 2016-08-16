class RemoveSortedByFromProtocolFilter < ActiveRecord::Migration
  def change
    remove_column :protocol_filters, :sorted_by
  end
end
