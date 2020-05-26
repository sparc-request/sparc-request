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

class CreateIrbRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :irb_records do |t|
      t.references  :human_subjects_info
      t.string      :pro_number
      t.string      :irb_of_record
      t.string      :submission_type
      t.date        :initial_irb_approval_date
      t.date        :irb_approval_date
      t.date        :irb_expiration_date
      t.boolean     :approval_pending

      t.timestamps
    end

    IrbRecord.reset_column_information

    HumanSubjectsInfo.all.each do |hsi|
      irb = hsi.irb_records.new

      irb.assign_attributes(hsi.attributes.except(
        'id', 'protocol_id', 'nct_number', 'deleted_at'
      ))

      irb.save
    end

    remove_column :human_subjects_info, :pro_number
    remove_column :human_subjects_info, :irb_of_record
    remove_column :human_subjects_info, :submission_type
    remove_column :human_subjects_info, :initial_irb_approval_date
    remove_column :human_subjects_info, :irb_approval_date
    remove_column :human_subjects_info, :irb_expiration_date
    remove_column :human_subjects_info, :approval_pending
  end
end
