# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class CreateEditableStatuses < ActiveRecord::Migration[5.0]
  def up
    create_table :editable_statuses do |t|
      t.references  :organization,  index: true, foreign_key: true
      t.string      :status,        null: false

      t.timestamps                  null: false
    end
    
    if defined?(EDITABLE_STATUSES)
      EDITABLE_STATUSES.each do |org_id, statuses|
        if organization = Organization.find_by_id(org_id)
          statuses.each do |status|
            organization.editable_statuses.create(status: status)
          end
        end
      end

      Organization.where.not(id: EDITABLE_STATUSES.keys).each do |org|
        PermissibleValue.get_key_list('status').each do |status|
          org.editable_statuses.create(status: status)
        end
      end
    else
      Organization.all.each do |org|
        PermissibleValue.get_key_list('status').each do |status|
          org.editable_statuses.create(status: status)
        end
      end
    end
  end

  def down
    drop_table :editable_statuses
  end
end
