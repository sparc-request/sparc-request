module Dashboard

  class ProtocolFinder

    def initialize(identity, params)
      @identity   = identity
      @params     = params
      @protocols  = Array.new
      @sort_col   = @params[:sort] || :protocol_id
    end

    def protocols
      protocols = find_identity_protocols

      promote_default_protocol if default_protocol_present? && !@params[:search]

      protocols
    end

    def total_protocols
      return @total_protocols if @total_protocols

      @total_protocols = Protocol.find_by_sql(query).count
    end

    private

    def promote_default_protocol
      default_protocol = Protocol.
        where(archived: include_archived?).
        for_identity(@identity).
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

    # assigns @identity_protocols to a page of desired protocols
    def find_identity_protocols
      return @identity_protocols if @identity_protocols

      query_pagination = (@params[:limit] ? "limit #{@params[:limit]}" : '') + (@params[:offset] ? " offset #{@params[:offset]}" : '')
      @identity_protocols = Protocol.find_by_sql(query + ' ' + query_pagination)
    end

    # SQL query that returns all the protocols user wants
    def query
      return @query if @query

      query_select     = "select distinct protocols.* from protocols"
      query_joins      = "inner join project_roles pr1 on pr1.protocol_id = protocols.id and pr1.role != \"none\" and pr1.identity_id = #{@identity.id}"
      query_where      = @params[:include_archived] != 'true' ? "where archived = 0" : 'where true'
      query_order      = ""

      if @params[:search] && @params[:search] != ''
        query_where = query_where + " and (short_title like \"%#{@params[:search]}%\" or protocols.id = #{@params[:search]})"
      end

      case @sort_col
      when 'pis'
        query_joins = query_joins + " left join project_roles pr2 on pr2.protocol_id = protocols.id and pr2.role = \"primary-pi\"
        left join identities on pr2.identity_id = identities.id"
        query_order = "order by last_name #{@params[:order]}"
      when 'id'
        query_order = "order by protocols.id #{@params[:order]}"
      when 'title'
        query_order = "order by protocols.short_title #{@params[:order]}"
      else
        query_order = "order by protocols.id desc"
      end

      @query = query_select + ' ' + query_joins + ' ' + query_where + ' ' + query_order
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
