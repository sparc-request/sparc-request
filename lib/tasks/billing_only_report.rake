namespace :reports do
  desc "Create billing only report for CWF"
  task :billing_only_report => :environment do

    start_date = "2015-07-01".to_date # start date
    end_date = "2015-07-31".to_date # end date

    # protocol_ids = [5730]
    protocol_ids = Protocol.all

    CSV.open("tmp/admin_billing_only_report.csv", "wb") do |csv|
      csv << ["From", start_date, "To", end_date]

      csv << [""]
      csv << [""]

      csv << ["Protocol ID", "Primary PI", "Patient Name", "Patient ID", "Visit Name", "Visit Date", "Service(s) Completed", "Quantity Completed", "Research Rate", "Total Cost"]

      protocol_ids.each do |id|
        protocol = Protocol.find(id)
        protocol.arms.each do |arm|
          arm.subjects.each do |subject|
            calendar = subject.calendar
            calendar.appointments.each do |appt|
              next unless appt.completed? && (appt.completed_at >= start_date && appt.completed_at <= end_date)
              visit_name = appt.name_switch
              visit_date = appt.formatted_completed_date

              appt.procedures.each do |procedure|
                next unless (procedure.should_be_displayed && procedure.completed?)
                r_qty = procedure.r_quantity

                research_rate = procedure.cost
                cost = research_rate * r_qty

                csv << [protocol.id, protocol.try(:primary_principal_investigator).try(:full_name), subject.name, subject.label, visit_name, visit_date, procedure.display_service_name, r_qty, research_rate, cost]
              end
            end
          end
        end
      end
    end
  end
end
