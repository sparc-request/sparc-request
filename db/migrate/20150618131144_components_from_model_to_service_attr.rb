# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

class ComponentsFromModelToServiceAttr < ActiveRecord::Migration
  
  class ServiceLevelComponent < ActiveRecord::Base
    attr_accessible :service_id
    attr_accessible :component
    attr_accessible :position
  end

  def up
    add_column :services, :components, :text
    remove_column :services, :service_level_components_count

    Service.all.each do |service|
      components_list = ""
      ServiceLevelComponent.where(service_id: service.id).each{ |slc| components_list += slc.component + "," }
      service.update_column(:components, components_list)
    end

    drop_table :service_level_components
  end

  def down
    create_table :service_level_components do |t|
      t.references :service
      t.string :component
      t.integer :position, default: 0

      t.timestamps
    end
    add_index :service_level_components, :service_id

    Service.all.each do |service|
      if service.components
        components_list = service.components.split(',')
        (0...components_list.length).each do |i|
          ServiceLevelComponent.create(service_id: service.id, component: components_list[i], position: i)
        end
      end
    end

    remove_column :services, :components
    add_column :services, :service_level_components_count, :integer
  end
end
