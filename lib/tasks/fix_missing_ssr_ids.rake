namespace :data do
  task fix_missing_ssr_ids: :environment do
    ssrs_with_missing_ssr_ids = SubServiceRequest.where(ssr_id: nil)

    puts "SSRs with missing ssr_ids - #{ssrs_with_missing_ssr_ids.count}"

    ssrs_with_missing_ssr_ids.each do |ssr|
      if ssr.protocol.next_ssr_id.nil?
        ssr.protocol.update_attribute(:next_ssr_id, 1)
        protocol_next_ssr_id = ssr.protocol.next_ssr_id
      else
        protocol_next_ssr_id = ssr.protocol.next_ssr_id
      end
      ssr.update_attribute(:ssr_id, "%04d" % protocol_next_ssr_id)
      puts "SSR updated with ssr_id of #{protocol_next_ssr_id}"
      ssr.protocol.update_attribute(:next_ssr_id, protocol_next_ssr_id + 1)
    end
  end
end
