module Dashboard

  class FixSsrIds

    def initialize(protocol)
      @protocol = protocol
    end

    def perform_id_fix
      requests = @protocol.sub_service_requests.group_by(&:ssr_id)
      if @protocol.sub_service_requests.present?
        last_ssr_id = @protocol.sub_service_requests.sort_by(&:ssr_id).last.ssr_id.to_i
        dup_requests_to_be_incremented = []

        requests.each do |ssr_id, ssr_array|
          if ssr_array.size > 1 # we have duplicate ssr_ids
            ssr_array.each_with_index do |ssr, index|
              if index > 0
                dup_requests_to_be_incremented << ssr # place all requests with dup ids in an array to deal with later
              end
            end
          end
        end

        if dup_requests_to_be_incremented.size > 0
          dup_requests_to_be_incremented.each do |ssr|
            ssr.ssr_id = "%04d" % (last_ssr_id + 1)
            ssr.save(validate: false) 
            last_ssr_id += 1
          end
        end

        # we need to increment the protocol's next_ssr_id if we had some duplicates
        new_last_ssr_id = @protocol.sub_service_requests.sort_by(&:ssr_id).last.ssr_id.to_i
        if @protocol.next_ssr_id? && (@protocol.next_ssr_id <= new_last_ssr_id)
          @protocol.next_ssr_id = new_last_ssr_id + 1
          @protocol.save(validate: false)
        end
      end
    end
  end
end