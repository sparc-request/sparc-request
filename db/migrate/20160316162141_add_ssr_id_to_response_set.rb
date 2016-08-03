# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddSsrIdToResponseSet < ActiveRecord::Migration
  def change
    add_column :response_sets, :sub_service_request_id, :integer
  end
end
