module Dashboard
  class IdentityOrganizations
    def initialize(id)
      @id = id
    end

    # returns organizations that have protocols and general user has access to
    def general_user_organizations_with_protocols
      Protocol.joins(:project_roles).where(project_roles: { identity_id: @id } ).where.not(project_roles: { project_rights: 'none' }).map(&:organizations).flatten.uniq
    end

    # returns organizations that have a service provider and super user access AND have protocols.
    def admin_organizations_with_protocols
      Organization.authorized_for_identity(@id).joins(:sub_service_requests)
    end
  end
end
