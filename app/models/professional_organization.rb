class ProfessionalOrganization < ApplicationRecord
  # In order from most general to least.
  ORG_TYPES = ['institution', 'college', 'department', 'division'].freeze
  audited

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
