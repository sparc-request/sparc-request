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

class MoveDataToArms < ActiveRecord::Migration

  class VisitGrouping < ActiveRecord::Base
    belongs_to :line_item
    belongs_to :arm
    has_many :visits
    attr_accessible :arm_id, :subject_count
  end

  class ServiceRequest < ActiveRecord::Base
    has_many :arms
    has_many :line_items
  end

  class LineItem < ActiveRecord::Base
    has_many :visits
    has_many :visit_groupings
  end

  class Visit < ActiveRecord::Base
  end

  class Arm < ActiveRecord::Base
    attr_accessible :name
    attr_accessible :visit_count
    attr_accessible :subject_count
  end

  def up
    LineItem.reset_column_information

    add_column :visits, :visit_grouping_id, :integer
    Visit.reset_column_information

    add_column :arms, :subject_count, :integer
    Arm.reset_column_information

    service_requests = ServiceRequest.all

    service_requests.each do |service_request|
      arm = service_request.arms.create! :name => 'ARM 1', :visit_count => service_request.visit_count, :subject_count => service_request.subject_count

      # Create a new visit grouping for each line item
      # (this really should have been only done for per-patient
      # per-visit line items; see the
      # remove_one_time_fee_line_items_from_arms migration for the fix)
      service_request.line_items.each do |line_item|
        visit_grouping = line_item.visit_groupings.create! :arm_id => arm.id, :subject_count => line_item.subject_count

        line_item.visits.each do |visit|
          visit.update_attribute :visit_grouping_id, visit_grouping.id
        end
      end
    end

    remove_column :service_requests, :visit_count
    remove_column :line_items, :subject_count
    remove_column :visits, :line_item_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
