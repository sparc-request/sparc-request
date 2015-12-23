class ConvertNotesToPolymorphic < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    add_column :notes, :sub_service_request_id, :integer
    add_column :notes, :appointment_id, :integer

    ssr_notes = Note.where("notable_type = SubServiceRequest")
    ssr_notes.each do |note|
      note.update_column(:sub_service_request_id, note.notable_id)
    end

    appointment_notes = Note.where("notable_type = Appointment")
    appointment_notes.each do |note|
      note.update_column(:appointment_id, note.notable_id)
    end

    remove_column :notes, :notable_id, :integer
    remove_column :notes, :notable_type, :string
  end
end
