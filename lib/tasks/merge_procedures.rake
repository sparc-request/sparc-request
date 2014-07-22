namespace :data do
  desc "Merge duplicated procedures"
  task :merge_procedures => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def merge_data app_id, line_item_id
      procs = Procedure.where("appointment_id = ? and line_item_id = ?", "#{app_id}", "#{line_item_id}")

      r_quantity = 0
      t_quantity = 0
      existing_visit = nil

      procs.each do |p|
        r_quantity = p.r_quantity if p.r_quantity && p.r_quantity > r_quantity
        t_quantity = p.t_quantity if p.t_quantity && p.t_quantity > t_quantity
        existing_visit = p if !p.visit.nil?
      end

      procs.reject! { |p| p == existing_visit }
      procs.each { |p| p.destroy }

      existing_visit.update_attribute(:r_quantity, r_quantity) if r_quantity != 0
      existing_visit.update_attribute(:t_quantity, t_quantity) if t_quantity != 0
    end

    arm_id = prompt "Enter the Arm ID to check for duplicate procedures : "
    arm = Arm.find arm_id
    puts "Checking for duplicates"
    dups = Hash.new(0)
    arm.subjects.each do |subject|
      s_appts = subject.calendar.appointments

      s_appts.each do |appt|
        appt.procedures.each do |proc|
          dups["#{proc.appointment_id} #{proc.line_item_id}"] += 1
        end
      end
    end

    answer = nil
    dups.each do |k, count|
      if count > 1
        answer = prompt "Duplicates were found. Would you like to merge data [Y/N]: "
        break
      else
        answer = "No dups found"
      end
    end

    if answer == 'Y' || answer == 'Yes'
      dups = dups.reject { |k, c| c == 1 }
      dups.each do |k, count|
        app_id, line_item_id = k.split(" ")
        merge_data app_id, line_item_id
      end
    elsif answer == 'No dups found'
      puts 'No duplicates found'
    else
      puts 'Data unchanged'
    end
  end
end

