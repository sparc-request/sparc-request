# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

class MoveStudyPhasesToIrbRecords < ActiveRecord::Migration[5.2]
  class ProtocolsStudyPhase < ApplicationRecord
    belongs_to :protocol
    belongs_to :study_phase
  end

  class IrbRecordsStudyPhase < ApplicationRecord
    belongs_to :irb_record
    belongs_to :study_phase
  end

  def change
    unless ActiveRecord::Base.connection.table_exists?(:irb_records_study_phases)
      create_table :irb_records_study_phases, id: false do |t|
        t.references :irb_record
        t.references :study_phase
      end
    end

    ActiveRecord::Base.transaction do
      ProtocolsStudyPhase.all.each do |psp|
        protocol = Protocol.where(id: psp.protocol_id).first

        if protocol && protocol.human_subjects_info && protocol.human_subjects_info.irb_records.any?
          irb_record  = protocol.human_subjects_info.irb_records.first

          IrbRecordsStudyPhase.create(
            irb_record_id: irb_record.id,
            study_phase_id: psp.study_phase_id
          )
        end
      end

      drop_table :protocols_study_phases
    end
  end
end
