namespace :data do
  desc "Reports to run after hospital services are imported"
  task :hospital_service_reports => :environment do
    cpt_grouped_records = Hash.new {|h,k| h[k] = [] }
    all_records = []
    CSV.foreach(ENV['file'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
      cpt_grouped_records[row['CPT Code']] << row
      all_records << row
    end

    CSV.open("/tmp/duplicate_cpt_codes.csv", "w+") do |csv|
      cpt_grouped_records.each do |cpt_code, rows|
        if rows.size > 1
          rows.each do |row|
            csv << row
          end
        end
      end
    end
    
    CSV.open("/tmp/non_duplicate_cpt_codes.csv", "w+") do |csv|
      cpt_grouped_records.each do |cpt_code, rows|
        if rows.size == 1
          rows.each do |row|
            csv << row
          end
        end
      end
    end

    CSV.open("/tmp/corporate_greater_than_service_rate.csv", "w+") do |csv|
      all_records.each do |row|
        full_rate = Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
        corporate_rate = Service.dollars_to_cents(row['Corporate Rate'].to_s.strip.gsub("$", "").gsub(",", ""))

        csv << row if corporate_rate > full_rate
      end
    end

    puts "Created /tmp/duplicate_cpt_codes.csv based off #{ENV['file']}"
    puts "Created /tmp/non_duplicate_cpt_codes.csv based off #{ENV['file']}"
    puts "Created /tmp/corporate_greater_than_service_rate.csv based off #{ENV['file']}"
  end
end
