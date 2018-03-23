class CreateResponseFilters < ActiveRecord::Migration[5.1]
  def up
    create_table :response_filters do |t|
      t.integer   :identity_id
      t.string    :of_type
      t.string    :with_survey
      t.datetime  :from_date
      t.datetime  :to_date
      t.boolean   :include_incomplete
      t.timestamps
    end
  end

  def down
    drop_table :response_filters
  end
end
