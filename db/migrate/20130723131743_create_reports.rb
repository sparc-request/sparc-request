class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.belongs_to :sub_service_request
      t.attachment :xlsx
      t.string :report_type
      t.timestamps
    end
  end
end
