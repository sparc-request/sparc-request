desc 'ssr_id_report'
task ssr_id_report: :environment do

  protocols = Protocol.all

  CSV.open("tmp/mismatched_ssr_ids.csv", "w+") do |csv|
    csv << ['Protocol ID', 'Protocol Next Ssr_id', 'Sub Service Request ID', "Protocol's Last SSRs Ssr_id"]

    protocols.each do |protocol|
      ssr = protocol.sub_service_requests.last
      if ssr && protocol.next_ssr_id
        if ("%04d" % (protocol.next_ssr_id - 1)) != ssr.ssr_id
          csv << [protocol.id, protocol.next_ssr_id, ssr.id, ssr.ssr_id]
        end
      end
    end
  end
end