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

class Appointment < ActiveRecord::Base
  audited

  belongs_to :calendar
  belongs_to :visit_group
  belongs_to :organization
  has_many :procedures, :dependent => :destroy
  has_many :visits, :through => :procedures
  has_many :notes, as: :notable
  attr_accessible :visit_group_id
  attr_accessible :organization_id
  attr_accessible :completed_at
  attr_accessible :position
  attr_accessible :name

  attr_accessible :procedures_attributes

  accepts_nested_attributes_for :procedures

  attr_accessible :formatted_completed_date

  def formatted_completed_date
    format_date self.completed_at
  end

  def formatted_completed_date=(d)
    self.completed_at = parse_date(d)
  end


  def populate_procedures(visits)
    columns =[:line_item_id,:visit_id,:toasts_generated, :appointment_id]
    values =[]
    visits.each do |visit|
      line_item = visit.line_items_visit.line_item
      if line_item.service.is_ctrc? && !line_item.service.one_time_fee
        values << [line_item.id,visit.id,true,self.id]
      end
    end
    if !(values.empty?)
      Procedure.import columns, values, {:validate=> true}
      self.reload
    end
  end

  def position_switch
    self.visit_group ? self.visit_group.position : self.position
  end

  def name_switch
    self.visit_group ? self.visit_group.name : self.name
  end

  def completed?
    if self.completed_at
      true
    else
      false
    end
  end
  
  def completed_for_core? (core_id)
    if self.completed? && (self.organization_id == core_id)
      return true
    else
      return false
    end
  end


  def display_name
    name_switch 
  end
  
  ### audit reporting methods ###
 
  def audit_label audit
    name_switch
  end

  def audit_field_value_mapping
    {"completed_at" => "'ORIGINAL_VALUE'.to_time.strftime('%Y-%m-%d')"}
  end
    
  def audit_excluded_actions
    ['create']
  end
  
  ### end audit reporting methods ###

  private

  def format_date(d)
    d.try(:strftime, '%-m/%d/%Y')
  end

  def parse_date(str)
    begin
      Date.strptime(str.to_s.strip, '%m/%d/%Y')  
    rescue ArgumentError => e
      nil
    end
  end


end
