class ConvertPaperclipAttachmentsToActivestorage < ActiveRecord::Migration[5.2]
  require 'open-uri'

  def change
    get_blob_id = 'LAST_INSERT_ID()'

    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
      INSERT INTO active_storage_blobs (
        `key`, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES (?, ?, ?, '{}', ?, ?, ?)
    SQL

    active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES (?, ?, ?, #{get_blob_id}, ?)
    SQL

    models = [Document, PaymentUpload, Report]

    transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          if c =~ /(.+)_file_name$/
            $1
          end
        end.compact

        if attachments.empty?
          next
        end

        model.find_each.each do |instance|
          attachments.each do |attachment|
            attachment_path = Dir[path_generator(instance, attachment)]
            if !attachment_path.empty?
              active_storage_blob_statement.execute(
                key(instance, attachment),
                instance.send("#{attachment}_file_name"),
                instance.send("#{attachment}_content_type"),
                instance.send("#{attachment}_file_size"),
                checksum(attachment_path[0]),
                instance.updated_at.iso8601
              )

              active_storage_attachment_statement.execute(
                attachment,
                model.name,
                instance.id,
                instance.updated_at.iso8601)
            end
          end
        end
      end
    end

    active_storage_attachment_statement.close
    active_storage_blob_statement.close
  end

  private

  def key(instance, attachment)
    filename = instance.send("#{attachment}_file_name")
    klass = instance.class.table_name
    id = instance.id
    id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)

    "#{klass}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
  end

  def checksum(path)
    Digest::MD5.base64digest(File.read(path))
  end

  def path_generator(instance, attachment)
    filename = instance.send("#{attachment}_file_name")
    klass = instance.class.table_name
    id = instance.id
    id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)

    Rails.root.join("public", "system", "#{klass}", "#{attachment.pluralize}", "#{id_partition}", "original", "*")
  end
end
