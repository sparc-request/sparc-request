class SetEpicFlagForProtocols < ActiveRecord::Migration
  def up
    protocols = Protocol.where("last_epic_push_time != ?", false)
    protocols.each do |protocol|
      protocol.selected_for_epic = true
      protocol.save
    end
  end

  def down
  end
end
