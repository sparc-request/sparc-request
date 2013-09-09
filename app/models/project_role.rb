class ProjectRole < ActiveRecord::Base
  audited

  belongs_to :protocol
  belongs_to :identity

  attr_accessible :protocol_id
  attr_accessible :identity_id
  attr_accessible :project_rights
  attr_accessible :role
  attr_accessible :role_other

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

  def validate_one_pi
    unless self.has_minimum_pi?
      errors.add(:must, "include one PI.") 
      return false
    end
    return true
  end

  def has_minimum_pi?
    other_project_roles = self.protocol.project_roles.reject {|x| x == self}
    all_project_roles = other_project_roles.map {|x| x.role}
    all_project_roles << self.role
    all_project_roles.include?('pi') ? true : false
  end

  def is_only_pi?
    if self.role == 'pi'
      pi_project_roles = self.protocol.project_roles.select {|x| x.role == 'pi'}
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

      if right == 'request' and role != 'pi'
        return true
      end
    end

    if (right == 'none' or right == 'view' or right == 'request') and role == 'pi'
      return false
    end

    return true
  end

  def should_select?(right, current_user)
    if project_rights == right
      return true
    end

    if role == 'pi' and right == 'approve'
      return true
    end

    if role == 'business-grants-manager' and right == 'approve'
      return true
    end

    if current_user == identity and role != 'pi' and right == 'request'
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
end

