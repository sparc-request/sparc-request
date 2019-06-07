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

class AddFlagForSelectedAvailableAndEditableStatuses < ActiveRecord::Migration[5.1]

  class AvailableStatus < ApplicationRecord
    def self.types
      PermissibleValue.where(category: 'status').pluck(:key)
    end
  end

  class EditableStatus < ApplicationRecord
    def self.types
      PermissibleValue.where(category: 'status').pluck(:key)
    end
  end

  def change
    add_column :available_statuses, :selected, :boolean, default: false
    add_column :editable_statuses, :selected, :boolean, default: false

    AvailableStatus.update_all(selected: true)

    ActiveRecord::Base.transaction do
      avs = []
      eds = []
      selected_eds = []
      Organization.includes(:available_statuses, :editable_statuses).each do |org|
        selected_eds += org.editable_statuses.where(status: org.available_statuses.selected.pluck(:status))
        avs += (AvailableStatus.types-  org.available_statuses.pluck(:status)).map{|status| AvailableStatus.new( organization: org, status: status )}
        eds += (EditableStatus.types - org.editable_statuses.pluck(:status)).map{|status| EditableStatus.new( organization: org, status: status )}
      end
      EditableStatus.where(id: selected_eds).update_all(selected: true)
      AvailableStatus.import avs
      EditableStatus.import eds
    end
  end
end
