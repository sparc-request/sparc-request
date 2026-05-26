namespace :audit do
  desc "Check selected SSRs from CSV for Fulfillment push blockers"
  task check_fulfillment_blockers: :environment do
    require 'csv'

    input_file  = Rails.root.join('tmp', 'service_requests_input.csv')
    output_file = Rails.root.join('tmp', 'service_requests_errors.csv')

    puts "Looking for input file at: #{input_file}"
    puts "File exists? #{File.exist?(input_file)}"

    headers = [
      "SPARC ID", "Organization", "Requested Services", "Status", "Status Date", "Can Push to CWF?", "Blocking Reasons", "Addl Protocol Message"
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
        epic_questions_answered = ""

        ssr = SubServiceRequest.includes(
                :organization,
                { :line_items => :service },
                :line_items_visits,
                :past_statuses,
                service_request: [:protocol, arms: :visit_groups]
              ).find_by(ssr_id: formatted_ssr_id, protocol_id: protocol_id)

        unless ssr
          csv << [display_id, nil, nil, nil, nil, "No", "SSR not found", epic_questions_answered]
          next
        end

        sr       = ssr.service_request
        protocol = sr.protocol
        requested_services = ssr.line_items.map { |li| li.service.name }.uniq.join("; ")
        status_date = ssr.past_statuses
                      .order(date: :desc)
                      .last
                      &.date
                      &.strftime("%m/%d/%Y")

        # Check if Protocol exists
        if protocol.nil?
          csv << [
            ssr.display_id,
            requested_services,
            status_date,
            ssr.organization&.name,
            ssr.status,
            "No",
            "Protocol is missing",
            epic_questions_answered
          ]
          next
        end

        # Check if RMID is present when required
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

        # Check if Epic study type questions are answered (not a push blocker, but useful to track)
        if protocol.is_a?(Study) && protocol.selected_for_epic
          epic_questions_answered = protocol.study_type_answers.any? { |a| a.answer.nil? } ? "Epic questions not answered" : ""
        end

        # Check if dates are valid. The errors this kicked back were not very legible to read if there were multiple errors
        # This was done to not have to touch the yml files
        protocol.validate_dates
        date_errors = protocol.errors.map(&:full_message).map do |msg|
          case msg
          when /recruitment_start_date|Estimate Recruitment Start Date/i
            "Recruitment Start Date must come before Recruitment End Date"
          when /recruitment_end_date|Estimated Recruitment End Date/i
            "Recruitment End Date must come after Recruitment Start Date"
          when /start_date/i
            "Start Date can't be blank"
          when /end_date/i
            "End Date can't be blank"
          else
            msg
          end
        end.uniq

        puts "DEBUG #{date_errors.inspect}"

        # Manually check end_date since the model has a typo, just in case
        if protocol.end_date.blank? && date_errors.none? { |e| e.downcase.include?("end date") }
          date_errors << "End date can't be blank"
        end

        blocking_errors += date_errors

        # Check if Protocol is valid
        protocol.bypass_rmid_validation = true
        sr.protocol_valid?
        blocking_errors += sr.errors.map(&:full_message)

        # Check if service details are valid (visit groups and arms)
        sr.service_details_valid?
        if sr.errors.any?
          protocol.arms.each do |arm|
            arm.visit_groups.each do |vg|
              if vg.day.blank?
                blocking_errors << "'#{arm.name}' - '#{vg.name}' is missing a calendar day."
              elsif vg.invalid?
                blocking_errors << "'#{arm.name}' - '#{vg.name}' has validation errors: #{vg.errors.map(&:full_message).join(', ')}"
              end
            end
          end
          blocking_errors += sr.errors.map(&:full_message).reject { |e| e.downcase.include?("arms")}
        end

        blocking_errors = blocking_errors.uniq

        puts "DEBUG #{ssr.display_id}: blocking_errors = #{blocking_errors.inspect}"

        csv << [
          ssr.display_id,
          ssr.organization&.name,
          requested_services,
          ssr.status,
          status_date,
          blocking_errors.empty? ? "Yes" : "No",
          blocking_errors.join("; "),
          epic_questions_answered
        ]
      end
    end

    puts "Rake task completed. Results written to #{output_file}"
  end
end