namespace :audit do
  desc "Check selected SSRs from CSV for Fulfillment push blockers"
  task check_fulfillment_blockers: :environment do
    require 'csv'

    input_file = Rails.root.join('tmp', 'service_requests_input.csv')
    output_file = Rails.root.join('tmp', 'service_requests_errors.csv')

    puts "Looking for input file at: #{input_file}"
    puts "File exists? #{File.exist?(input_file)}"

    headers = [
      "Display ID", "Protocol ID", "SSR ID", "Organization", "Status",
      "Can Push?", "Blocking Reasons"
    ]

    ssr_keys = []

    # Parse input CSV and extract protocol/SSR ID pairs from csv
    CSV.foreach(input_file, headers: true, col_sep: ',', liberal_parsing: true) do |row|
      display_id = row["Protocol ID (SRID)"]&.strip

      if display_id.present? && display_id.match?(/^\d+-\d+$/)
        protocol_id, ssr_id = display_id.split("-")
        ssr_keys << [protocol_id.to_i, ssr_id]
      else
        puts "Cannot read SSR ID on row: #{row.inspect}."
      end
    end

    puts "Found #{ssr_keys.size} SubService Requests"

    CSV.open(output_file, "w", write_headers: true, headers: headers) do |csv|
      ssr_keys.each do |protocol_id, ssr_id|
        ssr = SubServiceRequest.includes(:protocol, :organization, :line_items, :line_items_visits, service_request: [:protocol, :arms])
                               .find_by(ssr_id: "%04d" % ssr_id.to_i, protocol_id: protocol_id)

        unless ssr
          csv << ["#{protocol_id}-#{ssr_id}", protocol_id, ssr_id, nil, nil, "No", "SSR not found"]
          next
        end

        sr = ssr.service_request

        # Reset errors
        sr.errors.clear
        sr.protocol&.errors&.clear

        # Run validations that add to sr.errors
        sr.protocol_valid?(return_errors: true)
        sr.service_details_valid?
        sr.protocol.validate_dates

        # Collect unique errors
        blocking_errors = (sr.errors.full_messages.uniq + Array(sr.errors[:base])).uniq
        puts "DEBUG: blocking_errors = #{blocking_errors.inspect}"

        csv << [
          ssr.display_id,
          sr.protocol&.id,
          ssr.ssr_id,
          ssr.organization&.name,
          ssr.status,
          blocking_errors.empty? ? "Yes" : "No",
          blocking_errors.join("; ")
        ]
      end
    end

    puts "Done! Results written to #{output_file}"
  end
end