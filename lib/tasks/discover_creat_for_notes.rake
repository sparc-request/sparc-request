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
