namespace :data do
  desc "Create CSV report of all one time fee line items under a given provider"
  task :one_time_fee_report => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def get_user_provider_input
      providers = Organization.where(:type => "provider")
      puts ""
      puts "ID        Name"
      puts ""

      providers.each do |org|
        puts "#{org.id}".rjust(2) + "        " + "#{org.name}"
      end

      puts ""
      puts ""
      provider_id = prompt("Please enter one of the above provider ids you would like to run the report for: ")

      provider_id
    end

    def full_ssr_id(ssr)
    protocol = ssr.service_request.protocol

    "#{protocol.id}-#{ssr.ssr_id}"
    end

    # Determines whether or not to display the time totals for a line item's fulfillments. If any of the fulfillment's timeframes
    # are not "Min", don't show the total.
    def should_be_totaled? line_item
      should_total = true
      line_item.fulfillments.each do |fulfillment|
        if fulfillment.timeframe != "Min"
          should_total = false
        end
      end

      should_total
    end

    # Will either add a blank row or a total row of fulfillment times, depending on what should_be_totaled? returns
    def add_totaled_row csv, line_item, total
      if should_be_totaled?(line_item)
        row = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", total, ""]
        csv << row
      else
        row = []
        csv << row
      end
    end

    def build_one_time_fee_report csv, ssr, provider, program, core
      if ssr.service_request.protocol
        service_request_id = full_ssr_id(ssr)
        status = AVAILABLE_STATUSES[ssr.status]
        protocol_id = ssr.service_request.protocol.id
        short_title = ssr.service_request.protocol.short_title
        pi = ssr.service_request.protocol.try(:primary_principal_investigator).try(:full_name)
        owner = ssr.owner_id ? Identity.find(ssr.owner_id).full_name : ""

        ssr.line_items.each do |li|
          total = 0
          if li.service.is_one_time_fee? && (li.created_at.to_date > 2012-03-01)
            if li.fulfillments.empty?
              row = [protocol_id, service_request_id, status, short_title, pi, provider.abbreviation, program.abbreviation, core.blank? ? "" : core.abbreviation, owner, li.service.name, (li.in_process_date.to_date rescue nil), (li.complete_date.to_date rescue nil), "null", "null", "null", "null"]
              csv << row
            else
              li.fulfillments.each do |fulfillment|
                total += fulfillment.time.to_i
                row = [protocol_id, service_request_id, status, short_title, pi, provider.abbreviation, program.abbreviation, core.blank? ? "" : core.abbreviation, owner, li.service.name, (li.in_process_date.to_date rescue nil), (li.complete_date.to_date rescue nil), (fulfillment.date.to_date rescue nil), fulfillment.timeframe, fulfillment.time, fulfillment.notes]
                csv << row
              end
            end
            add_totaled_row(csv, li, total)
          end
        end
      end
    end

    # End of helper methods, begin generating the report
    provider_id = get_user_provider_input

    unless provider_id.blank?
      provider = Organization.find(provider_id)
     
      CSV.open("tmp/#{Date.today}_#{provider.abbreviation}_otf_report.csv", "wb") do |csv|
        row = ["PID", "SRID", "Status", "Short Title", "PI", "Provider", "Program", "Core", "Service Request Owner", "Service", "In Process", "Complete", "Fulfillment Date", "Timeframe", "Time", "Comments"]
        csv << row

        provider.programs.each do |program|
          program.sub_service_requests.each do |ssr|
            build_one_time_fee_report(csv, ssr, provider, program, "")
          end
          program.cores.each do |core|
            core.sub_service_requests.each do |ssr|
              build_one_time_fee_report(csv, ssr, provider, program, core)
            end
          end
        end
      end
    else
      puts "No provider id specified." 
    end
  end
end
