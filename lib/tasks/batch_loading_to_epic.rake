namespace :epic do
  desc "Batch load from Epic Queue"
  task :batch_load => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    confirm = prompt("Are you sure you want to batch load from the Epic Queue? (Yes/No) ")

    if confirm == "Yes"
      if EpicQueue.all.size > 0
        protocol_ids = EpicQueue.all.map(&:protocol_id)

        protocol_ids.each do |id|
          begin
            p = Protocol.find id

            p.push_to_epic(EPIC_INTERFACE)

            # loop until the push is either complete or fails
            while not ['complete', 'failed'].include? p.last_epic_push_status
              p.reload
              sleep 1
            end
  
            if p.last_epic_push_status == 'failed'
              puts "#{p.short_title} (#{p.id}) failed to send to Epic"
              Notifier.epic_queue_error(p).deliver
            else
              puts "#{p.short_title} (#{p.id}) sent to Epic"
              EpicQueue.find_by_protocol_id(p.id).destroy
            end
          rescue Exception => e
            puts e
          end
        end
      else
        puts "Epic Queue is empty"
      end
    else
      puts "Batch load aborted"
    end
  end
end
