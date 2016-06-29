class AddProtocolToDocuments < ActiveRecord::Migration
  def up
    add_column :documents, :protocol_id, :integer
    add_index :documents, :protocol_id

    Document.all.each do |doc|
      service_request = doc.service_request
      protocol = service_request.protocol

      puts "Document id   #{doc.id}"
      puts "Removing from Service Request id   #{service_request.id}"
      puts protocol.present? ? "Adding to Protocol id   #{protocol.id}" : "No associated Protocol found."

      doc.update_attribute(:protocol_id, protocol.id) if protocol.present?
    end

    remove_column :documents, :service_request_id
  end
end
