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

class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :type
      t.string :obisid
      t.integer :next_ssr_id
      t.string :short_title
      t.text :title
      t.string :sponsor_name
      t.text :brief_description
      t.decimal :indirect_cost_rate, :precision => 5, :scale => 2
      t.string :study_phase
      t.string :udak_project_number
      t.string :funding_rfa
      t.string :funding_status
      t.string :potential_funding_source
      t.datetime :potential_funding_start_date
      t.string :funding_source
      t.datetime :funding_start_date
      t.string :federal_grant_serial_number
      t.string :federal_grant_title
      t.string :federal_grant_code_id
      t.string :federal_non_phs_sponsor
      t.string :federal_phs_sponsor

      t.timestamps
    end

    add_index :protocols, :obisid
  end
end
