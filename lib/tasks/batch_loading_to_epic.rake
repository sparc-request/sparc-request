namespace :epic do
  desc "Batch load from Epic Queue"
  task :batch_load => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    confirm = prompt("Are you sure you want to batch load from the Epic Queue? (Yes/No) ")

    sent = []
    failed = []
    if confirm == "Yes"
      if EpicQueue.all.size > 0
        protocol_ids = EpicQueue.all.map(&:protocol_id)
        puts "Queue => #{protocol_ids.inspect.to_s}"

        protocol_ids.each do |id|
          begin
            p = Protocol.find id

            p.push_to_epic(EPIC_INTERFACE)

            # loop until the push is either complete or fails
            while not ['complete', 'failed'].include? p.last_epic_push_status
              p.reload
              sleep 1
            end


            if p.last_epic_push_status == 'failed' # i'm 99% sure this will never happen as failures get caught in the rescue block
              puts "#{p.short_title} (#{p.id}) failed to send to Epic"
              failed << p.id
              Notifier.epic_queue_error(p).deliver
            else
              puts "#{p.short_title} (#{p.id}) sent to Epic"
              sent << p.id
              EpicQueue.find_by_protocol_id(p.id).destroy
            end
          rescue Exception => e
            failed << p.id
            puts "#{p.short_title} (#{p.id}) failed to send to Epic with an exception"
            puts "Sent => #{sent.inspect.to_s}"
            puts "Failed => #{failed.inspect.to_s}"
            Notifier.epic_queue_error(p).deliver
            puts e
          end
        end
        puts "Sent => #{sent.inspect.to_s}"
        puts "Failed => #{failed.inspect.to_s}"
      else
        puts "Epic Queue is empty"
      end
    else
      puts "Batch load aborted"
    end
  end
end
