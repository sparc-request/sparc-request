module Dashboard

  class ProtocolFinder

    def initialize(identity, params)
      @identity   = identity
      @params     = params
      @protocols  = Array.new
    end

    def protocols
      protocols = find_identity_protocols

      promote_default_protocol if default_protocol_present?

      protocols
    end

    def total_protocols
      @total_protocols ||= Protocol.
                                where(archived: include_archived?).
                                joins(:project_roles).
                                  where(project_roles: { identity_id: @identity.id }).
                                  where.not(project_roles: { project_rights: 'none' }).
                                  distinct.
                                  count
    end

    private

    def promote_default_protocol
      default_protocol = Protocol.
        where(archived: include_archived?).
        joins(:project_roles).
          where(project_roles: { identity_id: @identity.id }).
          where.not(project_roles: { project_rights: 'none' }).
          where(id: @params[:default_protocol].to_i).
          first if @params[:default_protocol]

      if default_protocol
        # if promoted protocol already on @identity_protocols, move to top
        if promoted_protocol = @identity_protocols.delete(default_protocol)
          @identity_protocols.unshift promoted_protocol
        else
          # otherwise, drop last on @identity_protocols, and add default_protocol
          # to top
          @identity_protocols.pop
          @identity_protocols.unshift promoted_protocol
        end
      end
    end

    def default_protocol_present?
      @params[:default_protocol].present? &&
        @identity_protocols.any? &&
        @identity_protocols.
          map(&:id).
          include?(@params[:default_protocol].to_i)
    end

    def find_identity_protocols
      @identity_protocols ||= Protocol.
                                where(archived: include_archived?).
                                joins(:project_roles).
                                  where(project_roles: { identity_id: @identity.id }).
                                  where.not(project_roles: { project_rights: 'none' }).
                                order(id: :desc).
                                limit(@params[:limit]).
                                offset(@params[:offset]).
                                distinct
    end

    def include_archived?
      archived = [false]

      if @params[:include_archived] == 'true'
        archived.push true
      end

      archived
    end
  end
end
