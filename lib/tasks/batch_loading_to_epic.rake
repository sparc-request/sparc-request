namespace :epic do
  desc "Batch load from Epic Queue"
  task :batch_load, [:automate] => [:environment] do |t, args|
    args.with_defaults(:automate => false)

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def send_epic_queue_report
      eq = EpicQueue.all

      CSV.open("tmp/epic_queue_report.csv", "wb") do |csv|
        csv << [Time.now.strftime('%m/%d/%Y')]
        eq.each do |epic_queue|
          protocol = epic_queue.protocol

          csv << [protocol.id, protocol.short_title, protocol.funding_source]
          csv << ["First Name", "Last Name", "Email Address", "LDAP UID", "Role"]
          protocol.project_roles.each do |pr|
            csv << [pr.identity.first_name, pr.identity.last_name, pr.identity.email, pr.identity.ldap_uid, pr.role]
          end
          csv << []
          csv << []
        end
      end
      Notifier.epic_queue_report.deliver
    end

    if EpicQueue.all.size > 0
      confirm = "No"
      protocol_ids = []

      if args.automate
        confirm = "Yes"
        protocol_ids = EpicQueue.all.map(&:protocol_id)
      else
        single = prompt("Enter a single protocol ID or leave blank for all: ")

        if single.blank?
          protocol_ids = EpicQueue.all.map(&:protocol_id)
        else
          protocol_ids = [single.to_i]
        end

        confirm = prompt("Are you sure you want to batch load #{protocol_ids.inspect}? (Yes/No) ")
      end

      sent = []
      failed = []
      if confirm == "Yes"

        send_epic_queue_report

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
              q = EpicQueue.find_by_protocol_id(p.id) rescue false
              q.destroy if q
            end
          rescue Exception => e
            failed << p.id
            puts "#{p.short_title} (#{p.id}) failed to send to Epic with an exception"
            puts "Sent => #{sent.inspect.to_s}"
            puts "Failed => #{failed.inspect.to_s}"
            Notifier.epic_queue_error(p, e).deliver
            puts e
          end
        end
        puts "Sent => #{sent.inspect.to_s}"
        puts "Failed => #{failed.inspect.to_s}"
        
        Notifier.epic_queue_complete(sent, failed).deliver
      else
        puts "Batch load aborted"
      end
    else
      sent = []
      failed = []
      puts "Epic Queue is empty"
      Notifier.epic_queue_complete(sent, failed).deliver
    end
  end
end
