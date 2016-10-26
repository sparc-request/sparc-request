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

class Visit < ActiveRecord::Base
  self.per_page = 5

  include RemotelyNotifiable

  audited

  has_many :procedures
  has_many :appointments, :through => :procedures
  belongs_to :visit_group
  belongs_to :line_items_visit

  attr_accessible :line_items_visit_id
  attr_accessible :visit_group_id
  attr_accessible :quantity
  attr_accessible :billing
  attr_accessible :research_billing_qty  # (R) qty billed to the study/project
  attr_accessible :insurance_billing_qty # (T) qty billed to the patients insurance or third party
  attr_accessible :effort_billing_qty    # (%) qty billing to % effort

  after_save :set_arm_edited_flag_on_subjects

  validates :research_billing_qty, :numericality => {:only_integer => true}
  validates :insurance_billing_qty, :numericality => {:only_integer => true}
  validates :effort_billing_qty, :numericality => {:only_integer => true}

  # Find a Visit for the given "line items visit" and visit group.  This
  # creates the visit if it does not exist.
  def self.for(line_items_visit, visit_group)
    return Visit.find_or_create_by(line_items_visit_id: line_items_visit.id, visit_group_id: visit_group.id)
  end

  def set_arm_edited_flag_on_subjects
    self.visit_group.arm.set_arm_edited_flag_on_subjects
  end

  def cost(per_unit_cost = self.line_items_visit.per_unit_cost(self.line_items_visit.quantity_total))
    
    li = self.line_items_visit.line_item
    if li.applicable_rate == "N/A"
      return "N/A"
    elsif self.research_billing_qty >= 1
      return self.research_billing_qty * per_unit_cost
    else
      return nil
    end
  end

  def quantity_total
    return research_billing_qty.to_i + insurance_billing_qty.to_i + effort_billing_qty.to_i
  end

  # A check to see if the billing quantities have either been customized, or are set to the
  # default of research == 1, insurance == 0, and effort == 0
  def quantities_customized?
    ((research_billing_qty > 1) || (insurance_billing_qty > 0) || (effort_billing_qty > 0))
  end

  def position
    ##get position from visit_group
    return self.visit_group.position
  end

  def to_be_performed?
    self.research_billing_qty > 0
  end

  ### audit reporting methods ###

  def audit_label audit
    "#{line_items_visit.line_item.service.name} on #{visit_group.name}"
  end

  def audit_excluded_actions
    ['create']
  end
  ### end audit reporting methods ###
end
