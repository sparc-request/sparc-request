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
  desc "Import merged procedure data"
  task :import_merged_procedures => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    # Grab the protocol id
    # File should be located in tmp directory
    # File name merged_procedures_#{protocol_id}.csv
    protocol_id = prompt "Enter the Protocol ID : "

    # Import the data
    # Headers - Subject, Procedure, Visit Name, Appointment ID, Line Item ID, Visit Group ID, Merged R, Merged T, Merged Completed
    temp = CSV.foreach("tmp/merged_procedures_#{protocol_id}.csv", :headers => true) do |row|
      # Find the procedure
      appt_id = row["Appointment ID"]
      line_item_id = row["Line Item ID"]
      procedures = Procedure.where("appointment_id = #{appt_id} and line_item_id = #{line_item_id}")
      procedure = procedures.first

      # In case we didn't run the merger already lets not try to merge incorrect data
      if procedures.count > 1
        ids = procedures.map { |proc| proc.id }
        puts "Procedures not merged. Run merge procedures before continuing."
        puts "Procedure ID's : #{ids.join(', ').to_s}"
        next
      end

      # Get R, T, and Completed
      r_quantity = row["Merged R Quantity"].to_i
      t_quantity = row["Merged T Quantity"].to_i
      completed  = row["Merged Completed"].casecmp('true') == 0 ? true : false

      procedure.update_attributes(:r_quantity => r_quantity, :t_quantity => t_quantity, :completed => completed)
    end
    puts "Procedures have been updated."
  end
end