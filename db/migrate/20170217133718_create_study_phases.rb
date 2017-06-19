class CreateStudyPhases < ActiveRecord::Migration[4.2]
  def change
    create_table :study_phases do |t|
      t.integer :order
      t.string :phase
      t.integer :version, :default => 1
      t.timestamps null: false
    end

    study_phases_version_1 = ['0', 'I', 'Ia', 'Ib', 'II', 'IIa', 'IIb', 'III', 'IIIa', 'IIIb', 'IV']

    study_phases_version_1.each_with_index do |sp, index|
      StudyPhase.create(order: index + 1, phase: sp)
    end
  end
end
