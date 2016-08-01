# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddIndexProtocolIdOnArms < ActiveRecord::Migration
  def up
    add_index "arms", ["protocol_id"], :name => "index_arms_on_protocol_id"
  end

  def down
    remove_index "arms", ["protocol_id"], :name => "index_arms_on_protocol_id"
  end
end
