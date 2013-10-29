class MoveStartEndDatesToProtocol < ActiveRecord::Migration
  def up
  	add_column :protocols, :start_date, :datetime
  	add_column :protocols, :end_date, :datetime

    Protocol.reset_column_information

  	Protocol.all.each do |p|
      start_date = p.service_requests.minimum(:start_date)
      end_date = p.service_requests.maximum(:end_date)
  		p.update_attributes(start_date: start_date, end_date: end_date)
    end

  	remove_column :service_requests, :start_date
  	remove_column :service_requests, :end_date
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
