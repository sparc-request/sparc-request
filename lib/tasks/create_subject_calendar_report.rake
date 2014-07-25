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
            csv << [subject.audit_label(nil)]
            
            vg_row = [""]
            arm.visit_groups.each do |visit_group|
              vg_row << "#{visit_group.name} R Qty"
              vg_row << "#{visit_group.name} T Qty"
            end
            
            csv << vg_row

            line_item_ids.each do |lid|
              subject_procedures = Procedure.joins(:appointment => :visit_group).where(:line_item_id => lid, :appointments => {:calendar_id => calendar.id}).order("visit_groups.position")
              
              line_item = LineItem.find lid
              subject_procedure_row = [line_item.service.name]

              subject_procedures.each do |procedure|
                subject_procedure_row << procedure.r_quantity
                subject_procedure_row << procedure.t_quantity
              end

              csv << subject_procedure_row
            end
          end
        end
      end
    else
      puts "No protocol id specified"
    end

  end
end
