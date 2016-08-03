class AddSortedByToProtocolFilter < ActiveRecord::Migration
  def change
    add_column :protocol_filters, :sorted_by, :string
  end
end
