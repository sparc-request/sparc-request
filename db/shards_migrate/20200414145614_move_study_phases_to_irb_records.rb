class MoveStudyPhasesToIrbRecords < ActiveRecord::Migration[5.2]
  using_group(:shards)

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
