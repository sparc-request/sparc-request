class AddSsrIdToResponseSet < ActiveRecord::Migration
  def change
    add_column :response_sets, :sub_service_request_id, :integer
  end
end
