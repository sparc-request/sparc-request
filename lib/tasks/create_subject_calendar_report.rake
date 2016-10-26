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

namespace :data do
  desc "Create CSV report of individual subject calendar data"
  task :subject_calendar_report => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    protocol_id = prompt("Please enter a protocol id: ")

    unless protocol_id.blank?
      protocol = Protocol.find protocol_id

      CSV.open("tmp/protocol_#{protocol_id}_subject_calendar_report.csv", "wb") do |csv|
        protocol.arms.each do |arm|
          line_item_ids = arm.line_items.map(&:id)
          arm.subjects.each do |subject|
            calendar = subject.calendar

            row = [subject.audit_label(nil)]
            arm.visit_groups.each do |visit_group|
              row << "#{visit_group.name} (R Qty)"
              row << "#{visit_group.name} (T Qty)"
            end

            csv << row

            line_item_ids.each do |lid|
              subject_procedures = Procedure.joins(:appointment => :visit_group).where(:line_item_id => lid, :appointments => {:calendar_id => calendar.id}).order("visit_groups.position")

              line_item = LineItem.find lid
              subject_procedure_row = ["#{line_item.service.name} - LID##{line_item.id}"]

              subject_procedures.each do |procedure|
                subject_procedure_row << procedure.r_quantity
                subject_procedure_row << procedure.t_quantity
              end

              csv << subject_procedure_row
            end

            individual_subject_procedures = Procedure.joins(:appointment => :visit_group).where(:line_item_id => nil, :appointments => {:calendar_id => calendar.id}).order("visit_groups.position")

            individual_subject_procedures.each do |procedure|
              vg_position = procedure.appointment.visit_group.position
              row = ["#{procedure.service.name} - SID##{procedure.service_id}"]
              (vg_position - 1).times do
                row << ""
                row << ""
              end

              row << procedure.r_quantity
              row << procedure.t_quantity

              csv << row
            end

            csv << [""]
          end
        end
      end
    else
      puts "No protocol id specified"
    end

  end
end
