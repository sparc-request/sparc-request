class ConvertFulfillmentNotesToRegularNotes < ActiveRecord::Migration
  def self.up
    change_column :notes, :body, :text

    # This has the potential to lose fulfillment notes if 
    #  it doesn't have line_item > service_request > requester data
    Fulfillment.all.each do |f|
      note_string = f.read_attribute(:notes)
      if note_string.present? and note_string.length > 0
        line_item = f.line_item
        if line_item
          service_request = line_item.service_request
          if service_request
            requester = service_request.service_requester
            if requester
              note = Note.new(identity_id: requester.id, notable_id: f.id, notable_type: "Fulfillment", body: "(original note) - "+note_string)
              note.save_without_auditing
            end
          end
        end
      end
    end
    remove_column :fulfillments, :notes, :string
  end

  def self.down
    add_column :fulfillments, :notes, :string

    Fulfillment.all.each do |f|
      notes = Note.where("notable_id = '#{f.id}' and notable_type = 'Fulfillment'")
      if notes and notes.length > 0
        note_string = notes.map(&:body).join("\n")
        f.update_column(:notes, note_string)
        notes.delete_all
      end
    end
  end
end
