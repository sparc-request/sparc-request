desc "Usage: rake import_velos_protocols velos_protocols=tmp/velos_protocols.csv"
task import_velos_protocols: :environment do

  def create_study(row, primary_pi)
    study = Study.new(
                   short_title:              row['VELOS_SHORT_TITLE'],
                   title:                    row['VELOS_TITLE'],
                   funding_status:           (row['FUNDING_STATUS'] == 'FUNDED' ? 'funded' : 'pending_funding'),
                   funding_source:           (row['FUNDING_STATUS'] == 'FUNDED' ? row['FUNDING_SOURCE'].downcase : nil),
                   potential_funding_source: (row['FUNDING_STATUS'] != 'FUNDED' ? row['FUNDING_SOURCE'].downcase : nil),
                   research_master_id:       (row['RMID'] != nil ? row['RMID'].to_i : nil),
                   sponsor_name:             row['SPONSOR'],
                   selected_for_epic:        false)
    primary_pi_for_study = study.project_roles.build(
                        :identity_id => primary_pi.id, 
                        :project_rights => 'approve',
                        :role => 'primary-pi')
    research_types_info = study.build_research_types_info
    if study.valid? && primary_pi_for_study.valid? && research_types_info.valid?
      study.save
      primary_pi_for_study.save
      research_types_info.save
      ServiceRequest.create(protocol_id: study.id)
    else
      puts "#"*200
      puts "Error importing study"
      puts row
      puts "-"* 100
      puts study.errors.messages
      puts primary_pi_for_study.errors.messages
      puts research_types_info.errors.messages
    end

    study
  end

  ActiveRecord::Base.transaction do
    puts ""
    puts "<>"*50
    puts "Starting import"
    CSV.open("tmp/velos_studies_report.csv", "w+") do |csv|
      csv << ['Created/Existing', 'Study ID', 'Title', 'Primary PI']
      CSV.foreach(ENV['velos_protocols'], :headers => true) do |row|
        irb_number = row['IRB_NO']
        if row['PI_EMAIL']
          primary_pi = Identity.where(email: row['PI_EMAIL']).first
          if primary_pi
            if irb_number
              irb_record = IrbRecord.find_by_pro_number(irb_number)
              if irb_record
                protocol = irb_record.human_subjects_info.protocol
                puts "We have an existing protocol"
                csv << ['Existing', protocol.id, protocol.title, protocol.primary_pi.full_name]
              else
                puts "Creating study for #{primary_pi.full_name}"
                study = create_study(row, primary_pi)
                puts "Creating study with an id of #{study.id}"
                csv << ['Created', study.id, study.title, primary_pi.full_name]
              end  
            else
              puts "Creating study for #{primary_pi.full_name}"
              study = create_study(row, primary_pi)
              puts "Creating study with an id of #{study.id}"
              csv << ['Created', study.id, study.title, primary_pi.full_name]
            end
          end
        end
      end
    end
  end
end