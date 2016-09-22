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
  desc "Delete unused/duplicated procedures and appointments"
  task :destroy_appointments => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def ask_for_protocol_ids
      manual_protocol_ids = prompt "Enter the Protocol ID's or type ALL to check for duplicate appointments : "

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
                dups["#{subject.id} #{proc.visit_id} #{proc.line_item_id}"] += 1
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
      @appts_to_destroy[protocol_id] = []
      @procs_to_update[protocol_id] = []
      @update_quantities[protocol_id] = []

      procs = procs.reject { |k, c| c == 1 }

      max_procs = procs.values.max
      row = ["Subject", "Procedure", "Visit", "Appointment ID", "Line Item ID", "Visit ID", "Merged R Quantity", "Merged T Quantity", "Merged Completed"]
      max_procs.times {|index| row << "Procedure #{index+1} R Qty"; row << "Procedure #{index+1} T Qty"; row << "Procedure #{index+1} Completed";}

      csv << row

      procs.each do |k, count|
        subj_id, visit_id, line_item_id = k.split(' ')
        collect_appointments subj_id, visit_id, line_item_id, csv, protocol_id
      end
    end

    def generate_reports
      @dups.each do |protocol_id, procs|
        CSV.open("tmp/duplicated_appointments_#{protocol_id}.csv", 'wb') do |csv|
          duplicated_loop protocol_id, procs, csv
        end
        puts "Report for Protocol #{protocol_id} has been created"
      end

      merge_data
    end

    def collect_appointments subject_id, visit_id, line_item_id, csv, protocol_id
      # SQL Query for finding duplicate procedures
      # select distinct pr.*
      # from
      #    calendars        c
      #   join appointments a  on (c.id = a.calendar_id)
      #   join procedures   pr on (pr.appointment_id = a.id)
      # where c.id = 318 and pr.visit_id = 125678 and pr.line_item_id = 11232
      subject = Subject.find subject_id
      calendar = subject.calendar
      procs = Procedure.joins(appointment: :calendar).where("appointments.calendar_id = ? and visit_id = ? and line_item_id = ?", calendar.id, visit_id, line_item_id).order(:appointment_id)
      appointment_ids = procs.map { |proc| proc.appointment_id }.uniq
      line_item = LineItem.find line_item_id
      visit_group = procs.first.visit.visit_group

      r_quantity = 0
      t_quantity = 0
      completed = false
      existing_visit = procs.first

      appt_name = visit_group.name
      row = [subject.audit_label(nil), line_item.service.name, appt_name, appointment_ids.uniq.join(', ').to_s, line_item_id, visit_group.id]

      prev_quantity_data = []
      procs.each do |p|
        r_quantity = p.r_quantity if p.r_quantity && p.r_quantity > r_quantity
        t_quantity = p.t_quantity if p.t_quantity && p.t_quantity > t_quantity
        completed  = p.completed  if p.completed

        prev_quantity_data << (p.r_quantity || 0)
        prev_quantity_data << (p.t_quantity || 0)
        prev_quantity_data << (p.completed)
      end

      row << r_quantity
      row << t_quantity
      row << completed

      row += prev_quantity_data

      csv << row if completed || r_quantity > 0 || t_quantity > 0

      bad_procs = procs.reject { |p| p == existing_visit }
      @appts_to_destroy[protocol_id].concat bad_procs.map { |proc| proc.appointment_id }
      # @procs_to_update[protocol_id] << existing_visit
      # @update_quantities[protocol_id] << {:r_quantity => r_quantity, :t_quantity => t_quantity, :completed => completed}
    end

    def merge_data
      @dups.each do |protocol_id, procs|
        answer = prompt "Would you like to destroy duplicated appointments for #{protocol_id}? [Y/N]: "
        if answer == 'Y' || answer == 'Yes'
          Appointment.destroy(@appts_to_destroy[protocol_id].uniq)
          # @procs_to_update[protocol_id].each_with_index do |proc, index|
          #   update_quantity = @update_quantities[protocol_id][index]
          #   proc.update_attribute(:r_quantity, update_quantity[:r_quantity]) unless update_quantity[:r_quantity] == 0
          #   proc.update_attribute(:t_quantity, update_quantity[:t_quantity]) unless update_quantity[:t_quantity] == 0
          #   proc.update_attribute(:completed,  update_quantity[:completed])  unless update_quantity[:completed] == false
          # end

          # now that we've merged let's make sure everyones calendar is built out correctly
          # protocol = Protocol.find protocol_id
          # protocol.arms.each do |arm|
          #   arm.subjects.each do |subject|
          #     calendar = subject.calendar
          #     calendar.populate_on_request_edit
          #     calendar.build_subject_data
          #   end
          # end

          puts "Data for #{protocol_id} has been merged."
        else
          puts "Data unchanged for #{protocol_id}."
        end
      end
    end

    # Globals for task
    @protocols = nil
    @dups = Hash.new(0)
    @appts_to_destroy = Hash.new(0)
    @procs_to_update = Hash.new(0)
    @update_quantities = Hash.new(0)

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