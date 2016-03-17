class AddSsrIdToResponseSet < ActiveRecord::Migration
  def change
    add_column :response_sets, :ssr_id, :integer
  end
end
