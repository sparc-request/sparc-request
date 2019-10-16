task remove_test_protocols: :environment do

  protocol_ids = [5363, 5338, 6794, 7705, 8355, 8606, 9112, 9132, 9189, 9190, 9236,
                  9259, 9354, 9377, 9391, 9409, 9428, 9435, 9455, 9459, 9462, 9471,
                  9495, 9505, 9514, 9527, 9630, 9649, 9652, 9662, 9713, 9724, 9740,
                  9788, 9828, 9833, 9858, 9947, 9964, 9966, 9985, 10030, 10038, 10046,
                  10064, 10099, 10101, 10105, 10114, 10150, 10364, 10395, 10462, 10468,
                  10470, 10493, 10634, 10669, 10756, 10975, 11016, 11087, 11172, 11186,
                  11187, 11299, 11378, 11611, 11879, 11991, 12002, 12064, 12126, 12212,
                  12295, 12694, 12703, 12794, 12823, 12828, 12884, 12951, 13105, 13113,
                  13281, 13282, 13284, 13286, 13289, 13299, 13305, 13554, 13565, 13568,
                  13593, 13620, 13681, 13687, 13695, 13721, 13761, 13794]
  count = 0                
  CSV.open("tmp/deleted_protocols_report.csv", "w+") do |csv|
    csv << ['Protocol ID', 'Title', 'Primary PI', 'Archived']
    protocol_ids.each do |id|
      protocol = Protocol.where(id: id).first
      if protocol
        puts "Removing protocol #{id}"
        csv << [id, protocol.title, protocol.primary_principal_investigator.display_name, protocol.archived?]
        protocol.destroy
        count += 1
      else
        puts 'Protocol not found'
        csv << [id, '', '']
      end
    end
  end

  puts "There were #{protocol_ids.count} protocol ids and #{count} were destroyed."
end