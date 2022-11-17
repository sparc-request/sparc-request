# Copyright © 2011-2022 MUSC Foundation for Research Development~
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
