class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.belongs_to :subject
      
      t.timestamps
    end
  end
end
