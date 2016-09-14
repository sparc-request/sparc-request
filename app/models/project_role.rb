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

class ProjectRole < ActiveRecord::Base

  include RemotelyNotifiable

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
  attr_accessible :identity_attributes

  accepts_nested_attributes_for :epic_rights, :allow_destroy => true
  accepts_nested_attributes_for :identity

  validates :identity_id, :presence => true
  validates :role, :presence => true
  validates :project_rights, :presence => true

  scope :primary_pis, -> { where(role: "primary-pi") }

  def can_edit?
    !(project_rights == "view" || project_rights == "none")
  end

  def can_view?
    project_rights != 'none'
  end

  def unique_to_protocol?
    duplicate_project_roles = ProjectRole.where(protocol_id: self.protocol.id).select {|x| x.identity_id == self.identity_id}
    duplicate_project_roles << self
    if duplicate_project_roles.count > 1
      errors.add(:this, "user is already associated with this protocol.")
      return false
    end

    return true
  end

  def fully_valid?
    valid = self.valid?
    other_selections_valid = self.validate_other_selections
    one_primary_pi = self.validate_one_primary_pi

    return (valid && other_selections_valid && one_primary_pi)
  end

  def validate_other_selections
    role_other_filled = true
    credentials_other_filled = true

    if self.role == 'other'
      if self.role_other.nil? || (!self.role_other.nil? && self.role_other.blank?)
        role_other_filled = false
        errors.add(:must, "specify this User's Role.")
      end
    end

    if self.identity.credentials == 'other'
      if self.identity.credentials_other.nil? || (!self.identity.credentials_other.nil? && self.identity.credentials_other.blank?)
        credentials_other_filled = false
        errors.add(:must, "specify this User's Credentials.")
      end
    end

    return role_other_filled && credentials_other_filled
  end

  def validate_one_primary_pi
    pi_roles = self.protocol.project_roles.where(role: "primary-pi")
    if pi_roles.empty? || pi_roles.include?(self) && self.role != "primary-pi"
      errors.add(:role, "- Protocols must have a Primary PI.")
      return false
    else
      return true
    end
  end

  def is_only_primary_pi?
    if self.role == 'primary-pi'
      pi_project_roles = self.protocol.project_roles.select {|x| x.role == 'primary-pi'}
      return true if pi_project_roles.size == 1
    end

    return false
  end

  def can_switch_to?
    if role =='primary-pi'|| role == 'pi'
      return false
    else
      return true
    end
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

  def set_default_rights
    if role == "business-grants-manager" || role == "primary-pi" || role == "pi"
      self.project_rights = 'approve'
    end
  end

  def display_rights
    case project_rights
    when "none"    then "Member Only"
    when "view"    then "View Rights"
    when "request" then "Request/Approve Services"
    when "approve" then "Authorize/Change Study Charges"
    end
  end

  def setup_epic_rights(is_new=true)
    position = 1
    EPIC_RIGHTS.each do |right, description|
      epic_right = epic_rights.detect{|obj| obj.right == right}
      epic_right = epic_rights.build(:right => right, :new => is_new) unless epic_right
      epic_right.position = position
      position += 1
    end
    epic_rights.sort{|a, b| a.position <=> b.position}
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
    self
  end
end
