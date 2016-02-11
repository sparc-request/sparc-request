# Copyright © 2011 MUSC Foundation for Research Development
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

class PendingSubsidy < Subsidy
  audited
  before_save :default_values

  default_scope { where(status: "Pending") }

  def default_values
    self.status ||= 'Pending'
  end

  def grant_approval approver
    # Remove current approved subsidy if exists, save notes
    current_approved_subsidy = sub_service_request.approved_subsidy
    if current_approved_subsidy.present?
      notes = current_approved_subsidy.notes
      current_approved_subsidy.destroy
    end

    # Create new approved subsidy from pending attributes
    new_attributes = self.attributes.except("id", "status", "created_at", "updated_at", "deleted_at").merge!({approved_by: approver.id})
    newly_approved = ApprovedSubsidy.create(new_attributes)

    # Migrate notes to new approved subsidy
    notes.update_all(notable_id: newly_approved.id) if current_approved_subsidy.present? && notes.present?

    # Delete pending subsidy
    self.destroy

    return newly_approved
  end
end
