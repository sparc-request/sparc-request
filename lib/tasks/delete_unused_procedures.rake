namespace :data do
  desc "Delete unused/duplicated procedures and appointments"
  task :destroy_appointments => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def ask_for_protocol_ids
      manual_protocol_ids = prompt "Enter the Protocol ID's or type ALL to check for duplicate procedures : "

      if manual_protocol_ids.casecmp('ALL') == 0
        @protocols = Protocol.all
      else
        protocol_ids = manual_protocol_ids.gsub(/\s+/, "").split(",").map(&:to_i)
        @protocols = protocol_ids.map { |pid| Protocol.find pid }
      end
    end

    def check_for_duplicates
      puts 'Checking for duplicates'

      @protocols.each do |protocol|
        dups = Hash.new(0)
        protocol.arms.each do |arm|
          arm.subjects.each do |subject|
            s_appts = subject.calendar.appointments

            s_appts.each do |appt|
              appt.procedures.each do |proc|
                next if proc.line_item_id.nil?
                dups["#{subject.id} #{proc.visit_id} #{proc.line_item_id}"] += 1
              end
            end
          end
        end

        dups.each do |key, count|
          if count > 1
           @dups[protocol.id] = dups
           break
          end
        end
      end
    end

    # Globals for task
    @protocols = nil
    @dups = Hash.new(0)
    @procs_to_destroy = Hash.new(0)

    ask_for_protocol_ids
    check_for_duplicates

    if @dups.empty?
      puts 'No duplicates found'
    else
      puts "Duplicates were found in Protocol(s): #{@dups.keys.join(', ').to_s}"
    end

  end
end