class ConvertNotesToPolymorphic < ActiveRecord::Migration
  def self.up
    #Convert Notes Table
    change_column :notes, :body, :text
    add_column :notes, :notable_id, :integer
    add_column :notes, :notable_type, :string

    ssr_notes = Note.where("sub_service_request_id is not null")
    ssr_notes.each do |note|
      note.update_column(:notable_id, note.sub_service_request_id)
      note.update_column(:notable_type, "SubServiceRequest")
    end

    appointment_notes = Note.where("appointment_id is not null")
    appointment_notes.each do |note|
      note.update_column(:notable_id, note.appointment_id)
      note.update_column(:notable_type, "Appointment")
    end

    remove_column :notes, :sub_service_request_id, :integer
    remove_column :notes, :appointment_id, :integer

    add_index "notes", ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type", using: :btree
    add_index "notes", ["identity_id"], name: "index_notes_on_user_id", using: :btree

    #Convert Fulfillment Notes
    Fulfillment.all.each do |f|
      note_string = f.read_attribute(:notes)
      if note_string.present? and note_string.length > 0
        begin
          requester_id = f.line_item.service_request.service_requester_id
        rescue
          requester_id = nil
        end
        note = Note.new(identity_id: requester_id, notable_id: f.id, notable_type: "Fulfillment", body: note_string)
        note.save_without_auditing
      end
    end
    remove_column :fulfillments, :notes, :text

    #Convert Service Request Notes
    ServiceRequest.all.each do |sr|
      note_string = sr.read_attribute(:notes)
      if note_string.present? and note_string.length > 0
        note = Note.new(identity_id: sr.service_requester.id, notable_id: sr.id, notable_type: "ServiceRequest", body: note_string)
        note.save_without_auditing
      end
    end
    remove_column :service_requests, :notes, :text
  end

  def self.down
    #Revert Service Request Notes
    add_column :service_requests, :notes, :text
    all_sr_notes = Note.where("notable_type = 'ServiceRequest'")
    srs_dealt_with = []
    all_sr_notes.each do |note|
      sr_id = note.notable_id
      next if srs_dealt_with.include?(sr_id)
      sr_notes = all_sr_notes.where("notable_id = '#{sr_id}'")
      unless sr_notes.empty?
        sr = ServiceRequest.find(sr_id)
        sr.update_column(:notes, sr_notes.map(&:body).join("\n"))
      end
      srs_dealt_with << sr_id
    end
    all_sr_notes.delete_all

    #Revert Fulfillment Notes
    add_column :fulfillments, :notes, :text
    all_f_notes = Note.where("notable_type = 'Fulfillment'")
    fs_dealt_with = []
    all_f_notes.each do |note|
      f_id = note.notable_id
      next if fs_dealt_with.include?(f_id)
      f_notes = all_f_notes.where("notable_id = '#{f_id}'")
      unless f_notes.empty?
        f = Fulfillment.find(f_id)
        f.update_column(:notes, f_notes.map(&:body).join("\n"))
      end
      fs_dealt_with << f_id
    end
    all_f_notes.delete_all

    #Revert Notes Table
    remove_index "notes", name: "index_notes_on_notable_id_and_notable_type"
    remove_index "notes", name: "index_notes_on_user_id"

    add_column :notes, :sub_service_request_id, :integer
    add_column :notes, :appointment_id, :integer

    ssr_notes = Note.where("notable_type = 'SubServiceRequest'")
    ssr_notes.each do |note|
      note.update_column(:sub_service_request_id, note.notable_id)
    end

    appointment_notes = Note.where("notable_type = 'Appointment'")
    appointment_notes.each do |note|
      note.update_column(:appointment_id, note.notable_id)
    end

    remove_column :notes, :notable_id, :integer
    remove_column :notes, :notable_type, :string
  end
end
