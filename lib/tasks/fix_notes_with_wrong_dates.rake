# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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

