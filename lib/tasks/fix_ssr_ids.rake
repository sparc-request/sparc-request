desc 'Fix ssr_ids'
task fix_ssr_ids: :environment do

  CSV.open("tmp/corrected_ssr_ids.csv", "w+") do |csv|
    csv << ['Protocol ID', 'Protocol Next Ssr_id', 'Sub Service Request ID', "Protocol's Last SSRs Ssr_id"]

    Protocol.find_each do |protocol|
      requests = protocol.sub_service_requests
      last = requests.index(requests.last)

      requests.each_with_index do |ssr, index|
        if (index > 0) && (ssr.ssr_id == requests[index - 1].ssr_id)
          csv << [protocol.id, protocol.next_ssr_id, ssr.id, ssr.ssr_id]
          incremented_id = ssr.ssr_id.to_i + 1
          ssr.ssr_id = "%04d" % incremented_id
          ssr.save(validate: false)
        end

        if (index == last) && (protocol.next_ssr_id?) && (protocol.next_ssr_id <= ssr.ssr_id.to_i)
          protocol.next_ssr_id = ssr.ssr_id.to_i + 1
          protocol.save(validate: false)
        end
      end
    end
  end
end