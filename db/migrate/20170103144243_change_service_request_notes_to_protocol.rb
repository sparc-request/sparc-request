class ChangeServiceRequestNotesToProtocol < ActiveRecord::Migration
  def change
    Note.includes(:notable).where(notable_type: 'ServiceRequest').each do |note|
      if note.notable
        note.update_attributes(notable_type: 'Protocol', notable_id: note.notable.protocol_id)
      end
    end
  end
end
