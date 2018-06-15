class ChangeDatetimeToStrings < ActiveRecord::Migration[5.2]
  def change
    change_column :response_filters, :start_date, :string
    change_column :response_filters, :end_date, :string
  end
end
