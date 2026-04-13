namespace :audit do
  desc "Check selected SSRs from CSV for Fulfillment push blockers"
  task check_fulfillment_blockers: :environment do
    require 'csv'

    input_file  = Rails.root.join('tmp', 'service_requests_input.csv')
    output_file = Rails.root.join('tmp', 'service_requests_errors.csv')

    puts "Looking for input file at: #{input_file}"
    puts "File exists? #{File.exist?(input_file)}"

    headers = [
      "Display ID", "Protocol ID", "SSR ID", "Organization", "Status", "Can Push?", "Blocking Reasons"
    ]

    ssr_keys = []

    CSV.foreach(input_file, headers: true, col_sep: ',', liberal_parsing: true) do |row|
      display_id = row["Protocol ID (SRID)"]&.strip

      if display_id.present? && display_id.match?(/^\d+-\d+$/)
        protocol_id, ssr_id = display_id.split("-")
        ssr_keys << [protocol_id.to_i, ssr_id]
      else
        puts "Cannot read SSR ID on row: #{row.inspect}."
      end
    end

    puts "Found #{ssr_keys.size} SubServiceRequests to check"

    CSV.open(output_file, "w", write_headers: true, headers: headers) do |csv|
      ssr_keys.each do |protocol_id, ssr_id|
        formatted_ssr_id = "%04d" % ssr_id.to_i
        display_id       = "#{protocol_id}-#{formatted_ssr_id}"
        blocking_errors  = []

        ssr = SubServiceRequest.includes(
                :organization,
                :line_items,
                :line_items_visits,
                service_request: [:protocol, arms: :visit_groups]
              ).find_by(ssr_id: formatted_ssr_id, protocol_id: protocol_id)

        unless ssr
          csv << [display_id, protocol_id, formatted_ssr_id, nil, nil, "No", "SSR not found"]
          next
        end

        sr       = ssr.service_request
        protocol = sr.protocol

        # Check if Protocol exists
        if protocol.nil?
          csv << [
            ssr.display_id,
            nil,
            ssr.ssr_id,
            ssr.organization&.name,
            ssr.status,
            "No",
            "Protocol is missing"
          ]
          next
        end

        # Check if Protocol is valid
        protocol.bypass_rmid_validation = true
        sr.protocol_valid?
        blocking_errors += sr.errors.full_messages

        # Check if RMID present when required
        rmid_required = !protocol.bypass_rmid_validation &&
                        Setting.get_value('research_master_enabled') &&
                        protocol.has_human_subject_info? &&
                        protocol.is_a?(Study)

        # Check again with RMID bypass off
        rmid_required = Setting.get_value('research_master_enabled') &&
                        protocol.has_human_subject_info? &&
                        protocol.is_a?(Study)

        if rmid_required && protocol.research_master_id.blank?
          blocking_errors << "Research Master ID is required but missing"
        end

        # Check if dates are valid
        protocol.validate_dates
        date_errors = protocol.errors.full_messages

        # Manually check end_date since the model has a typo, just in case
        if protocol.end_date.blank? && date_errors.none? { |e| e.downcase.include?("end date") }
          date_errors << "End date can't be blank"
        end

        blocking_errors += date_errors

        # Check if service details are valid (visit groups and arms)
        sr.service_details_valid?
        blocking_errors += sr.errors.full_messages

        blocking_errors = blocking_errors.uniq

        puts "DEBUG #{ssr.display_id}: blocking_errors = #{blocking_errors.inspect}"

        csv << [
          ssr.display_id,
          protocol.id,
          ssr.ssr_id,
          ssr.organization&.name,
          ssr.status,
          blocking_errors.empty? ? "Yes" : "No",
          blocking_errors.join("; ")
        ]
      end
    end

    puts "Rake task completed. Results written to #{output_file}"
  end
end