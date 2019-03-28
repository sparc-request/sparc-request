class RemoveHrNumber < ActiveRecord::Migration[5.2]
  class HumanSubjectsInfo < ApplicationRecord
  end

  def up
    ActiveRecord::Base.transaction do
      CSV.open("tmp/hr_number_export.csv", "wb") do |csv|
        csv << [
          'Protocol ID',
          'HR Number'
        ]

        Protocol.includes(:human_subjects_info).where.not(human_subjects_info: { hr_number: [nil,''] }).each do |p|
          csv << [
            p.id,
            p.human_subjects_info.hr_number
          ]
        end
      end

      remove_column :human_subjects_info, :hr_number
    end
  end

  def down
    add_column :human_subjects_info, :hr_number, :string

    if File.exists?('tmp/hr_number_export.csv')
      ActiveRecord::Base.transaction do
        CSV.parse(File.read('tmp/hr_number_export.csv'), headers: true).each do |row|
          Protocol.find(row[0]).human_subjects_info.update_attribute(:hr_number, row[1])
        end
      end
    end
  end
end
