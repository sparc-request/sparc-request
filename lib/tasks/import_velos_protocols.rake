desc "Usage: rake import_velos_protocols velos_protocols=tmp/velos_protocols.csv"
task import_velos_protocols: :environment do

  count = 0
  CSV.open("tmp/existing_studies.csv", "w+") do |csv|
    csv << ['Protocol Id', 'Title', 'Primary PI']
    CSV.foreach(ENV['velos_protocols'], :headers => true) do |row|
      irb_number = row['IRB_NO']
      if row['PI_EMAIL']
        identity = Identity.where(email: row['PI_EMAIL']).first
        if identity
          puts identity.inspect
          count += 1
        end
      end
      if irb_number
        irb_record = IrbRecord.find_by_pro_number(irb_number)
        if irb_record
          protocol = irb_record.human_subjects_info.protocol
          
          csv << [protocol.id, protocol.title, protocol.primary_pi.full_name]
        end
      end
    end
  end
  puts count
end
# study = Study.new(
#                    :short_title => row['Short Title'],
#                    :title => row['Protocol Title'],
#                    :funding_status => (row['Funded'] == 'Y' ? 'funded' : 'pending_funding'),
#                    :funding_source => (row['Funded'] == 'Y' ? FUNDING_SOURCES[row['Funding Source']] : nil),
#                    :potential_funding_source => (row['Funded'] != 'Y' ? POTENTIAL_FUNDING_SOURCES[row['Funding Source']] : nil),
#                    :sponsor_name => row['Sponsor'])

# study.requester_id = ppi.id

# primary_pi = study.project_roles.build(
#                                   :identity_id => ppi.id, 
#                                   :project_rights => 'approve',
#                                   :role => 'primary-pi')