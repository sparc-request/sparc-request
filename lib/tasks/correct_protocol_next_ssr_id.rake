desc 'correct_protocol_next_ssr_id'
task correct_protocol_next_ssr_id: :environment do

  CSV.open("tmp/corrected_ssr_ids.csv", "w+") do |csv|
    csv << ['Protocol ID', 'Protocol Next Ssr_id', 'Sub Service Request ID', "Protocol's Last SSRs Ssr_id"]

    Protocol.find_each do |protocol|
      ssr = protocol.sub_service_requests.last
      if ssr && protocol.next_ssr_id
        if ("%04d" % (protocol.next_ssr_id)) == ssr.ssr_id
          csv << [protocol.id, protocol.next_ssr_id, ssr.id, ssr.ssr_id]
          protocol.next_ssr_id = protocol.next_ssr_id + 1
          protocol.save(validate: false)
        end
      end
    end
  end
end