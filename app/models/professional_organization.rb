# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

class ProfessionalOrganization < ApplicationRecord
  # In order from most general to least.
  ORG_TYPES = ['institution', 'college', 'department', 'division'].freeze
  audited

  belongs_to :parent, class_name: "ProfessionalOrganization"

  scope :institutions, -> {
    where(org_type: 'institution')
  }

  scope :colleges, -> {
    where(org_type: 'college')
  }

  scope :departments, -> {
    where(org_type: 'department')
  }

  scope :divisions, -> {
    where(org_type: 'division')
  }

  # Returns collection like [greatgrandparent, grandparent, parent].
  def parents
    parent ? (parent.parents + [parent]) : []
  end

  scope :institutions, -> { where(org_type: 'institution').order(:name) }

  # Returns collection like [greatgrandparent, grandparent, parent, self].
  def parents_and_self
    parents + [self]
  end

  def children
    ProfessionalOrganization.where(parent_id: id)
  end

  def self_and_siblings
    ProfessionalOrganization.where(parent_id: parent_id)
  end
end
