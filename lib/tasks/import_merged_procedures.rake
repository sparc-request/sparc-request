namespace :data do
  desc "Import merged procedure data"
  task :import_merged_procedures => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    # Grab the protocol id
    # File should be located in tmp directory
    # File name merged_procedures_#{protocol_id}.csv
    protocol_id = prompt "Enter the Protocol ID : "

    # Import the data
    # Headers - Subject, Procedure, Visit Name, Appointment ID, Line Item ID, Visit Group ID, Merged R, Merged T, Merged Completed
    temp = CSV.foreach("tmp/merged_procedures_#{protocol_id}.csv", :headers => true) do |row|
      # Find the procedure
      appt_id = row["Appointment ID"]
      line_item_id = row["Line Item ID"]
      procedures = Procedure.where("appointment_id = #{appt_id} and line_item_id = #{line_item_id}")
      procedure = procedures.first

      # In case we didn't run the merger already lets not try to merge incorrect data
      if procedures.count > 1
        ids = procedures.map { |proc| proc.id }
        puts "Procedures not merged. Run merge procedures before continuing."
        puts "Procedure ID's : #{ids.join(', ').to_s}"
        next
      end

      # Get R, T, and Completed
      r_quantity = row["Merged R Quantity"].to_i
      t_quantity = row["Merged T Quantity"].to_i
      completed  = row["Merged Completed"].casecmp('true') == 0 ? true : false

      procedure.update_attributes(:r_quantity => r_quantity, :t_quantity => t_quantity, :completed => completed)
    end
    puts "Procedures have been updated."
  end
end