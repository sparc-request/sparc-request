# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

namespace :data do
  desc "Merge duplicated procedures"
  task :merge_procedures => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def ask_for_protocol_ids
      manual_protocol_ids = prompt "Enter the Protocol ID's or type ALL to check for duplicate procedures : "

      if manual_protocol_ids.casecmp('ALL') == 0
        @protocols = Protocol.all
      else
        protocol_ids = manual_protocol_ids.gsub(/\s+/, "").split(",").map(&:to_i)
        @protocols = protocol_ids.map { |pid| Protocol.find pid }
      end
    end

    def check_for_duplicates
      puts 'Checking for duplicates'

      @protocols.each do |protocol|
        dups = Hash.new(0)
        protocol.arms.each do |arm|
          arm.subjects.each do |subject|
            s_appts = subject.calendar.appointments

            s_appts.each do |appt|
              appt.procedures.each do |proc|
                next if proc.line_item_id.nil?
                dups["#{proc.appointment_id} #{proc.line_item_id}"] += 1
              end
            end
          end
        end

        dups.each do |key, count|
          if count > 1
           @dups[protocol.id] = dups
           break
          end
        end
      end
    end

    def duplicated_loop protocol_id, procs, csv
      @procs_to_destroy[protocol_id] = []
      @procs_to_update[protocol_id] = []
      @update_quantities[protocol_id] = []

      procs = procs.reject { |k, c| c == 1 }

      max_procs = procs.values.max
      row = ["Subject", "Procedure", "Visit", "Appointment ID", "Line Item ID", "Visit Group ID", "Merged R Quantity", "Merged T Quantity", "Merged Completed"]
      max_procs.times {|index| row << "Procedure #{index+1} R Qty"; row << "Procedure #{index+1} T Qty"; row << "Procedure #{index+1} Completed";}

      csv << row

      procs.each do |k, count|
        app_id, line_item_id = k.split(' ')
        collect_procedures app_id, line_item_id, csv, protocol_id
      end
    end

    def generate_reports
      @dups.each do |protocol_id, procs|
        CSV.open("tmp/duplicated_procedures_#{protocol_id}.csv", 'wb') do |csv|
          duplicated_loop protocol_id, procs, csv
          if csv.lineno() == 1
            csv << ["Procedures were duplicated but no information was changed."]
            csv << ["A merge is recommended to clean up duplicated procedures."]
          end
        end
      end
      
      puts "Report(s) for Protocol(s) #{@dups.keys.join(', ').to_s} have been created"
      
      merge_data
    end

    def collect_procedures app_id, line_item_id, csv, protocol_id
      procs = Procedure.where("appointment_id = ? and line_item_id = ?", "#{app_id}", "#{line_item_id}")
      appointment = Appointment.find app_id
      line_item = LineItem.find line_item_id

      r_quantity = 0
      t_quantity = 0
      completed = false
      existing_visit = nil
      # 5439, 5590, 5882, 6213, 6257, 6307, 6319, 6358, 6633
      appt_name = appointment.visit_group_id ? appointment.visit_group.name : appointment.name
      row = [appointment.calendar.subject.audit_label(nil), line_item.service.name, appt_name, app_id, line_item_id, appointment.visit_group_id]

      prev_quantity_data = []
      procs.each do |p|
        r_quantity = p.r_quantity if p.r_quantity && p.r_quantity > r_quantity
        t_quantity = p.t_quantity if p.t_quantity && p.t_quantity > t_quantity
        completed  = p.completed  if p.completed

        prev_quantity_data << (p.r_quantity || 0)
        prev_quantity_data << (p.t_quantity || 0)
        prev_quantity_data << (p.completed)

        existing_visit = p if !p.visit.nil?
      end

      row << r_quantity
      row << t_quantity
      row << completed

      row += prev_quantity_data

      csv << row if completed || r_quantity > 0 || t_quantity > 0

      @procs_to_destroy[protocol_id].concat procs.reject { |p| p == existing_visit }
      @procs_to_update[protocol_id] << existing_visit
      @update_quantities[protocol_id] << {:r_quantity => r_quantity, :t_quantity => t_quantity, :completed => completed}
    end

    def merge_data
      @dups.each do |protocol_id, procs|
        answer = prompt "Would you like to merge procedures for #{protocol_id}? [Y/N]: "
        if answer == 'Y' || answer == 'Yes'
          @procs_to_destroy[protocol_id].each { |proc| proc.destroy }
          @procs_to_update[protocol_id].each_with_index do |proc, index|
            update_quantity = @update_quantities[protocol_id][index]
            proc.update_attribute(:r_quantity, update_quantity[:r_quantity]) unless update_quantity[:r_quantity] == 0
            proc.update_attribute(:t_quantity, update_quantity[:t_quantity]) unless update_quantity[:t_quantity] == 0
            proc.update_attribute(:completed,  update_quantity[:completed])  unless update_quantity[:completed] == false
          end

          # now that we've merged let's make sure everyones calendar is built out correctly
          protocol = Protocol.find protocol_id
          protocol.arms.each do |arm|
            arm.subjects.each do |subject|
              calendar = subject.calendar
              calendar.populate_on_request_edit
              calendar.build_subject_data
            end
          end

          puts "Data for #{protocol_id} has been merged."
        else
          puts "Data unchanged for #{protocol_id}."
        end
      end
    end

    # Globals for task
    @protocols = nil
    @dups = Hash.new(0)
    @procs_to_destroy = Hash.new(0)
    @procs_to_update = Hash.new(0)
    @update_quantities = Hash.new(0)

    # Start of task
    ask_for_protocol_ids
    check_for_duplicates

    # Prompt for duplicates
    if @dups.empty?
      puts 'No duplicates found'
    else
      puts "Duplicates were found in Protocol(s): #{@dups.keys.join(', ').to_s}"
      answer = prompt 'Would you like a report of what will be merged? [Y/N]: '
      if answer.casecmp('Y') == 0
        generate_reports
      else
        @dups.each do |protocol_id, procs|
          csv = []
          duplicated_loop protocol_id, procs, csv
        end

        merge_data
      end
    end
  end
end

