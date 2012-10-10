class AddRequesterToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :requester_id, :integer
  end
end
