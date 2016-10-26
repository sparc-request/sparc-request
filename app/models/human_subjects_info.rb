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

class HumanSubjectsInfo < ActiveRecord::Base

  include RemotelyNotifiable
  
  audited
  
  self.table_name = 'human_subjects_info'

  belongs_to :protocol

  attr_accessible :protocol_id
  attr_accessible :nct_number
  attr_accessible :hr_number
  attr_accessible :pro_number
  attr_accessible :irb_of_record
  attr_accessible :submission_type
  attr_accessible :irb_approval_date
  attr_accessible :irb_expiration_date
  attr_accessible :approval_pending

  validates :nct_number, :numericality => {:allow_blank => true, :only_integer => true, :message => "must contain 8 numerical digits"}
  validates :nct_number, :length => {:allow_blank => true, :is => 8, :message => "must contain 8 numerical digits"}

  def irb_and_pro_numbers
    string = ""
    string += "HR # #{self.hr_number} " unless hr_number.blank?
    string += "PRO # #{self.pro_number} " unless pro_number.blank?
  end
end

