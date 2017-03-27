namespace :data do
  task :move_rm_medications_to_muha => :environment do
    muha = Organization.find_by_name('MUHA-Medical University Hospital Authority')
    rm_medications = Organization.find_by_name('Research Medications/Drugs')

    rm_medications.update_attribute(:parent_id, muha.id)
  end
end
