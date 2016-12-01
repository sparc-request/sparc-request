class ProfessionalOrganization < ActiveRecord::Base
  # In order from most general to least.
  ORG_TYPES = ['institution', 'college', 'department', 'division'].freeze
  audited

  attr_accessible :name
  attr_accessible :org_type
  attr_accessible :depth # might not be needed
  attr_accessible :parent_id

  belongs_to :parent, class_name: "ProfessionalOrganization"

  # Returns collection like [greatgrandparent, grandparent, parent].
  def parents
    parent ? (parent.parents + [parent]) : []
  end

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
