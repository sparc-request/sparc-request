# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
