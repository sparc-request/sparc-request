module Portal

  class ProtocolFinder

    def initialize(user, params)
      @user       = user
      @params     = params
      @protocols  = Array.new
    end

    def protocols
      promote_default_protocol if default_protocol_present?

      user_protocols
    end

    private

    def promote_default_protocol
      default_protocol = @user_protocols.select{ |protocol| protocol.id == params[:default_protocol].to_i }

      if default_protocol = @user_protocols.delete(default_protocol)
        @user_protocols.unshift default_protocol
      end
    end

    def default_protocol_present?
      params[:default_protocol].present? && @user_protocols.map(&:id).include?(params[:default_protocol].to_i)
    end

    def user_protocols
      @user_protocols ||= Array.new

      @user.protocols.each do |protocol|
        if protocol.project_roles.find_by_identity_id(@user.id).project_rights != 'none'
          if include_archived || !protocol.archived
            @user_protocols.push protocol
        end
      end

      if @user_protocols.any?
        @user_protocols.
          sort_by { |protocol| (protocol.id || '0000') + protocol.id }.
          reverse
      end

      @user_protocols
    end

    def include_archived?
      @params[:include_archived] == 'true'
    end
  end
end

  def find_protocols
    @protocols        = []
    include_archived  = params[:include_archived] == 'true'

    @user.protocols.each do |protocol|
      if protocol.project_roles.find_by_identity_id(@user.id).project_rights != 'none'
        if include_archived || !protocol.archived
          @protocols.push protocol
      end
    end
    @protocols = @protocols.sort_by { |pr| (pr.id || '0000') + pr.id }.reverse

    if params[:default_protocol] && @protocols.map(&:id).include?(params[:default_protocol].to_i)
      protocol = @protocols.select{ |p| p.id == params[:default_protocol].to_i}[0]
      @protocols.delete(protocol)
      @protocols.insert(0, protocol)
    end
  end
