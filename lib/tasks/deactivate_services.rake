desc "Deactivate services designated in CSV"

task deactivate_services: :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_file(error=false)
    puts "No import file specified or the file specified does not exist in db/imports" if error
    file = prompt "Please specify the file name to import from db/imports (must be a CSV, see db/imports/example.csv for formatting): "

    while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
      file = get_file(true)
    end

    file
  end

  skipped_services = CSV.open("tmp/skipped_active_services_#{Time.now.strftime('%m%d%Y%T')}.csv", "wb")
  skipped_services << ['EAP ID', 'CPT Code', 'Revenue Code', 'Skipped Because']

  input_file = Rails.root.join("db", "imports", get_file)
  continue = prompt('Preparing to modify the services. Are you sure you want to continue? (y/n): ')

  if (continue == 'y') || (continue == 'Y')
    ActiveRecord::Base.transaction do
      CSV.foreach(input_file, headers: true) do |row|
        service = Service.find_by(eap_id: row["EAP ID"], cpt_code: row["CPT Code"], revenue_code: row["Revenue Code"])

        if service
          service.assign_attributes({ is_available: false, audit_comment: 'by script' })
          service.save
          puts "Deactivated #{service.name}"
        else
          skipped_services << [row["EAP ID"], row["CPT Code"], row["Revenue Code"], "service not found"]
        end
      end
    end
  else
    puts "Exiting rake task..."
  end
end
