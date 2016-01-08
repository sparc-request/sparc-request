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

    private

    def promote_default_protocol
      default_protocol = @identity_protocols.
                          select { |protocol| protocol.id == @params[:default_protocol].to_i }.
                          first

      if promoted_protocol = @identity_protocols.delete(default_protocol)
        @identity_protocols.unshift promoted_protocol
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
                                  where('project_roles.identity_id = ?', @identity.id).
                                  where('project_roles.project_rights != ?', 'none').
                                uniq.
                                sort_by { |protocol| (protocol.id || '0000') + protocol.id }.
                                reverse
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
