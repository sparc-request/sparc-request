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

class ProjectRole < ActiveRecord::Base
  audited

  belongs_to :protocol
  belongs_to :identity

  has_many :epic_rights, :dependent => :destroy

  attr_accessible :protocol_id
  attr_accessible :identity_id
  attr_accessible :project_rights
  attr_accessible :role
  attr_accessible :role_other
  attr_accessible :epic_access
  attr_accessible :epic_rights_attributes

  accepts_nested_attributes_for :epic_rights, :allow_destroy => true

  validates :role, :presence => true
  validates :project_rights, :presence => true

  def validate_uniqueness_within_protocol
    duplicate_project_roles = self.protocol.project_roles.select {|x| x.identity_id == self.identity_id}
    duplicate_project_roles << self
    if duplicate_project_roles.count > 1
      errors.add(:this, "user is already associated with this protocol.")
      return false
    end

    return true
  end

  def validate_one_primary_pi
    unless self.has_minimum_pi?
      errors.add(:must, "include one Primary PI.")
      return false
    end
    return true
  end

  def has_minimum_pi?
    other_project_roles = self.protocol.project_roles.reject {|x| x == self}
    all_project_roles = other_project_roles.map {|x| x.role}
    all_project_roles << self.role
    all_project_roles.include?('primary-pi') ? true : false
  end

  def is_only_primary_pi?
    if self.role == 'primary-pi'
      pi_project_roles = self.protocol.project_roles.select {|x| x.role == 'primary-pi'}
      return true if pi_project_roles.size == 1
    end

    return false
  end

  def can_switch_to?(right, current_user)
    # none, view, request, approve
    
    if current_user == identity
      if right == 'none' or right == 'view'
        return false
      end

      if right == 'request' and role != 'pi' and role != 'primary-pi'
        return true
      end
    end

    if (right == 'none' or right == 'view' or right == 'request') and (role == 'pi' || role == 'primary-pi')
      return false
    end

    return true
  end

  def should_select?(right, current_user)
    if project_rights == right
      return true
    end

    if (role == 'pi' || role == 'primary-pi') and right == 'approve'
      return true
    end

    if role == 'business-grants-manager' and right == 'approve'
      return true
    end

    if current_user == identity and role != 'pi' and role != 'primary-pi' and right == 'request'
      return true
    end

    return false
  end

  def display_rights
    case project_rights
    when "none"    then "Member Only"
    when "view"    then "View Rights"
    when "request" then "Request/Approve Services"
    when "approve" then "Authorize/Change Study Charges"
    end
  end

  def setup_epic_rights is_new=true
    position = 1
    EPIC_RIGHTS.each do |right, description|
      epic_right = epic_rights.detect{|obj| obj.right == right}
      epic_right = epic_rights.build(:right => right, :new => is_new) unless epic_right
      epic_right.position = position
      position += 1
    end
    epic_rights.sort!{|a, b| a.position <=> b.position}
  end

  def populate_for_edit
    if USE_EPIC
      setup_epic_rights
    end
  end

  def set_epic_rights
    if USE_EPIC
      if self.role == 'primary-pi'
        rights = setup_epic_rights(false)
        self.epic_access = true
        self.epic_rights = rights
      end
    end
  end
end

