class AddNameToFeedbacks < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    add_column :feedbacks, :name, :string, after: :message
  end
end
