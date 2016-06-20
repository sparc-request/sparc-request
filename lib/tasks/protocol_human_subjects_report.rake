namespace :reports do
  desc "Create human subject report for all protocols"
  task :protocol_human_subjects_report => :environment do

    protocols = Protocol.all

    CSV.open("tmp/protocol_human_subjects_report.csv", "wb") do |csv|
      csv << ["Protocol ID", "Primary PI", "Human Subjects Checked?", "Pro/HR Number", "IRB Approval date", "IRB Expiration Date"]

      def has_pppv_services(protocol)
        service_requests = protocol.service_requests.where("status != ?", "first_draft")
        service_requests.keep_if{|sr| sr.has_per_patient_per_visit_services?}
        service_requests.any?
      end

      def hsi_formatter(protocol)
        protocol.human_subjects_info ? "Yes" : "No"
      end

      def hsi_fields_formatter(protocol)
        if protocol.human_subjects_info
          hsi = protocol.human_subjects_info
          [hsi.irb_and_pro_numbers, hsi.irb_approval_date ? hsi.irb_approval_date.strftime("%D") : "", hsi.irb_expiration_date ? hsi.irb_expiration_date.strftime("%D") : ""]
        else
          ["N/A", "N/A", "N/A"]
        end
      end

      protocols.each do |protocol|
        next unless has_pppv_services(protocol)
        csv << ([protocol.id, protocol.try(:primary_principal_investigator).try(:full_name), hsi_formatter(protocol), hsi_fields_formatter(protocol)].flatten)
      end
    end
  end
end
