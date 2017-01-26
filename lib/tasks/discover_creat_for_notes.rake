require 'progress_bar'

task :discover_creat_for_notes => :environment do
  puts "ID, Notable Type, Created At"
  notes_to_fix = Note.where('created_at between "2016-06-20 19:15:00" and "2016-06-20 19:19:00"')
  fixed_count = 0

  # Separate into Fulfillment and ServiceRequest notes
  fulfillment_notes_to_fix, sr_notes_to_fix = notes_to_fix.partition do |note|
    note.notable_type == 'Fulfillment'
  end

  fulfillment_notes_to_fix.each do |note|
    # Look through fulfillment's audits to discover that the time the notes
    # column was updated.
    last_notes_col_update = AuditRecovery.where(auditable_id: note.notable_id, auditable_type: 'Fulfillment').reverse.find do |audit|
      audit.audited_changes['notes']
    end

    if last_notes_col_update
      puts "#{note.id}, #{note.notable_type}, #{last_notes_col_update.created_at}"
      note.update_columns(created_at: last_notes_col_update.created_at)
      fixed_count += 1
    else
      puts "#{note.id}, #{note.notable_type}, ?"
    end
  end

  # Some of sr_notes_to_fix belong to Protocols now, so we need to find what
  # ServiceRequest they used to belong to.
  sr_notes_to_fix.each do |note|
    sr_id = note.notable_id

    last_notes_col_update = AuditRecovery.where(auditable_id: sr_id, auditable_type: 'ServiceRequest').reverse.find do |audit|
      audit.audited_changes['notes']
    end

    if last_notes_col_update
      puts "#{note.id}, #{note.notable_type}, #{last_notes_col_update.created_at}"
      note.update_columns(created_at: last_notes_col_update.created_at)
      fixed_count += 1
    else
      puts "#{note.id}, #{note.notable_type}, ?"
    end
  end

  puts "Fixed: #{fixed_count}; Unfixed: #{notes_to_fix.count}"
end
