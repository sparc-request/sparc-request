namespace :data do
  task fix_notes_with_wrong_dates: :environment do
    client = Mysql2::Client.new(Rails.configuration.database_configuration['sparc_backup'])

    notes_with_wrong_dates = []

    File.foreach(Rails.root.join('public', 'notes_report_skipped.txt')) do |line|
      notes_with_wrong_dates << line.to_i
    end

    notes_to_fix = Note.where(id: notes_with_wrong_dates)

    puts "There are #{notes_to_fix.count} notes that have the wrong date"

    puts 'This task takes quite a while, might be a good idea to stretch your legs or get a coffee...'

    fulfillments = client.query('SELECT * FROM fulfillments')

    service_requests = client.query('SELECT * FROM service_requests')

    fixed_notes = []

    fulfillments.each do |row|
      note = notes_to_fix.find_by(body: row['notes'])
      unless note.nil?
        note.update_attributes(created_at: row['created_at'], updated_at: row['updated_at'])
        fixed_notes << note
      end
    end

    service_requests.each do |row|
      note = notes_to_fix.find_by(body: row['notes'])
      unless note.nil?
        note.update_attributes(created_at: row['created_at'], updated_at: row['updated_at'])
        fixed_notes << note
      end
    end

    puts "#{fixed_notes.count} notes have been updated in our database"
  end
end

