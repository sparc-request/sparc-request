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
  desc "List services rendered and their costs"
  task :service_list_count => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    # One for 1/1/14 - 12/31/14
    # And one 7/1/13 - 6/30/14
    # I need the service name, the service rate (meaning the actual cost of
    # the service - not one of the discounted rates), how many times it was
    # performed during those time periods and indicated as R, how many times
    # it was performed during those time periods and indicated as T, Total R$
    # for the service during those time periods, and Total T$. I'm sending you an example.

    start_date = prompt "Enter the starting date (2014-01-01): "
    end_date   = prompt "Enter the ending date (2014-01-01): "

    CSV.open("tmp/service_list_#{start_date}_to_#{end_date}.csv","wb") do |csv|
      csv << ["Service", "Service Rate", "Federal Rate", "Qty R Performed", "Qty T Performed", "Total R $", "Total T $"]
      procs = Procedure.joins(:appointment).where("completed = true and appointments.completed_at between '#{start_date}' and '#{end_date}'")

      totals = Hash.new(0)

      puts "Looping over procedures: #{procs.count}"
      procs.each do |p|
        service = p.service || p.line_item.service
        pricing_map = service.effective_pricing_map_for_date(p.appointment.completed_at)
        full_rate = pricing_map.full_rate
        federal_rate = pricing_map.federal_rate || full_rate
        r = p.r_quantity || 0
        t = p.t_quantity || 0

        if totals[service.name] == 0
          totals[service.name] = { "#{pricing_map.id}" => { r_quantity: r, t_quantity: t, full_rate: full_rate, federal_rate: federal_rate } }
        elsif totals[service.name]["#{pricing_map.id}"].nil?
          totals[service.name]["#{pricing_map.id}"] = { r_quantity: r, t_quantity: t, full_rate: full_rate, federal_rate: federal_rate }
        else
          totals[service.name]["#{pricing_map.id}"][:r_quantity] += r
          totals[service.name]["#{pricing_map.id}"][:t_quantity] += t
        end
      end

      puts "Creating rows"
      totals.each do |name, value|
        value.each do |id, quantity|
          r_qty = quantity[:r_quantity]
          t_qty = quantity[:t_quantity]
          cost  = quantity[:full_rate].to_i
          csv << [name, cost / 100.0, quantity[:federal_rate].to_i / 100.0, r_qty, t_qty, r_qty * cost / 100.0, t_qty * cost / 100.0]
        end
      end
    end
  end
end