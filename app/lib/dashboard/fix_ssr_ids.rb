module Dashboard

  class FixSsrIds

    def initialize(protocol, merged_ssr_ids)
      @protocol = protocol
      @next_ssr_id = protocol.next_ssr_id
      @merged_ssr_ids = merged_ssr_ids
    end

    def perform_id_fix
      id = @next_ssr_id
      if @merged_ssr_ids.count != 0
        @merged_ssr_ids.each do |ssr_id|
          ssr = SubServiceRequest.find(ssr_id)
          ssr.ssr_id = "%04d" % id
          id += 1
          ssr.save(validate: false)
        end

        @protocol.next_ssr_id = id
        @protocol.save(validate: false)
      end
    end
  end
end