namespace :data do
  desc "Import rates frm DHHS rate file"
  task :import_dhhs_rates => :environment do
    begin
      #### import dhhs rates,  CSV format should be From,Thru,Amount,ORG ID
      next_version = RevenueCodeRange.maximum('version').to_i+1

      CSV.foreach(ENV['rate_file'], :headers => true) do |row|
        from = row['From'].strip[0..3].to_i
        thru = row['Thru'].strip[0..3].to_i
        percentage = row['Amount'].to_f
        org_id = row['ORG ID'].to_i

        puts "Revenue code range for organization #{org_id} is #{from} to #{thru} at #{percentage}%"
    
        RevenueCodeRange.create :from => from, :to => thru, :percentage => percentage, :applied_org_id => org_id, :vendor => 'dhhs', :version => next_version
      end
    rescue Exception => e
      puts "Usage: rake data:import_dhhs_rates rate_file=tmp/rate_file.csv"
      puts e.message
    end
  end
end
