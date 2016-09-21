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

class ApprovedSubsidy < Subsidy
  audited
  before_save :default_values
  belongs_to :approver, class_name: 'Identity', foreign_key: "approved_by"

  attr_accessible :total_at_approval
  attr_accessible :approved_by
  attr_accessible :approved_at

  default_scope { where(status: "Approved") }

  def default_values
    self.status             ||= 'Approved'
    self.approved_at        ||= Time.now
    self.total_at_approval  ||= total_request_cost
  end

  def approved_cost
    # Calculates cost of subsidy (amount subsidized)
    # stored total - pi_contribution then convert from cents to dollars
    ( total_at_approval - pi_contribution ) / 100.0
  end

  def log_approval_note
    # Creates a note logging the details of the subsidy's approval
    approval_string = \
      "<table class='table table-bordered table-condensed'><thead>"\
      "<tr><h4>Subsidy Approved</h4></tr>"\
      "<tr><th>Request Cost</th><th>% Subsidy</th><th>PI Contribution</th><th>Subsidy Cost</th></tr>"\
      "</thead><tbody><tr>"\
      "<td>#{total_at_approval/100.0}</td>"\
      "<td>#{percent_subsidy}</td>"\
      "<td>#{(pi_contribution/100.0)}</td>"\
      "<td>#{approved_cost}</td>"\
      "</tr></tbody></table>"
    notes.create(body: approval_string, identity_id: approver.id)
  end
end
