desc "Usage: rake import_velos_protocols velos_protocols=tmp/velos_protocols.csv"
task import_velos_protocols: :environment do

  def fix_name_strings(name)
    if name.size == 3
      name.delete_at(1)
    end

    name
  end

  CSV.foreach(ENV['velos_protocols'], :headers => true) do |row|
    irb_number = row['IRB_NO']
    if irb_number
      name = fix_name_strings(row['PI_NAME'].split(' '))
      identity = Identity.where(last_name: name[1]).where(first_name: name[0]).first
      irb_record = IrbRecord.find_by_pro_number(irb_number)
      if irb_record
        protocol = irb_record.human_subjects_info.protocol
      end
      if identity
        count += 1
      else
        puts name.inspect
      end
    end
  end
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