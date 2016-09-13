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
