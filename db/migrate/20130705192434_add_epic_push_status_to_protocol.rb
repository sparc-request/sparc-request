class AddEpicPushStatusToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :last_epic_push_time, :datetime
    add_column :protocols, :last_epic_push_status, :string
  end
end
