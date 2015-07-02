namespace :reports do
  desc "Create nexus IRB expiration report"
  task :irb_nexus_report => :environment do

    start_date = "2015-05-01".to_date # start date
    end_date = "2015-05-31".to_date # end date

    protocols = HumanSubjectsInfo.where("DATE(irb_expiration_date) between ? and ?", start_date, end_date).order(:irb_expiration_date)
                .map(&:protocol)
                .select{|protocol| protocol.has_nexus_services?}

    CSV.open("tmp/nexus_irb_expiration_report.csv", "wb") do |csv|
      csv << ["From", start_date]
      csv << ["To", end_date]

      csv << [""]
      csv << [""]

      csv << ["Protocol ID", "IRB Expiration Date"]

      protocols.each do |protocol|
        csv << [protocol.id, protocol.human_subjects_info.irb_expiration_date.strftime('%m/%d/%Y')]
      end
    end
  end
end
