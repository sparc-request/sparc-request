# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class CreatePastSubsidies < ActiveRecord::Migration

  class PastSubsidy < ActiveRecord::Base
    attr_accessible :pi_contribution
    attr_accessible :sub_service_request_id
    attr_accessible :total_at_approval
    attr_accessible :approved_by
    attr_accessible :approved_at
  end

  def change
    create_table :past_subsidies do |t|
      t.integer :sub_service_request_id
      t.integer :total_at_approval
      t.integer :pi_contribution
      t.integer :approved_by
      t.datetime :approved_at

      t.timestamps
    end

    add_index :past_subsidies, :sub_service_request_id
    add_index :past_subsidies, :approved_by

    Note.where(notable_type: 'Subsidy').each do |note|
      p = PastSubsidy.new
      p.sub_service_request_id = Subsidy.find(note.notable_id).sub_service_request_id

      data = note.body.split('<td>')
      p.total_at_approval = (data[1].sub('</td>', '').to_f * 100).to_i
      p.pi_contribution   = (data[3].sub('</td>', '').to_f * 100).to_i
      p.approved_by       = note.identity_id
      p.approved_at       = note.created_at

      note.destroy

      p.save
    end
  end
end
