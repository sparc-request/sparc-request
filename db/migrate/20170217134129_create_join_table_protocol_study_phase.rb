class CreateJoinTableProtocolStudyPhase < ActiveRecord::Migration[4.2]
  def change
    create_join_table :protocols, :study_phases do |t|
      t.index [:protocol_id, :study_phase_id]
      t.index [:study_phase_id, :protocol_id]
    end

    # Populate join table
    Protocol.all.each do |protocol|
      if protocol.read_attribute(:study_phase).present?
        old_study_phases = { 'I'=> 'i', 'II'=> 'ii', 'III'=> 'iii', 'IV'=> 'iv' }
        old_study_phase_of_protocol = old_study_phases.select{ |k, v| v == protocol.read_attribute(:study_phase) }
        all_study_phases = StudyPhase.all
        study_phase = all_study_phases.select{ |sp| sp.phase == old_study_phase_of_protocol.keys.first }
        protocol.study_phases << study_phase
        protocol.save
      end
    end
  end
end
