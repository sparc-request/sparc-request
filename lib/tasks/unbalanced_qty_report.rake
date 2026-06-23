
# Copyright © 2011-2026 MUSC Foundation for Research Development~
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

require 'progress_bar'

desc "Report to show unbalanced line_items_visit qty sum to visit qty"
task :unbalanced_qty_report => :environment do

  CSV.open(Rails.root.join('tmp', 'unbalanced_qty_report.csv'), 'wb') do |csv|
    csv << ['Protocol', 'Arm', 'Service', 'LineItemsVisit (LIV) ID', 'R Qty Issue', 'LIV R Qty', 'Visits R Qty Sum', 'I Qty Issue', 'LIV I Qty', 'Visits I Qty Sum', 'E Qty Issue', 'LIV E Qty', 'Visits E Qty Sum']

    bar = ProgressBar.new(LineItemsVisit.count)

    LineItemsVisit.all.each do |liv|
      r_qty_sum = liv.visits.sum(:research_billing_qty)
      i_qty_sum = liv.visits.sum(:insurance_billing_qty)
      e_qty_sum = liv.visits.sum(:effort_billing_qty)

      if liv.visit_r_quantity != r_qty_sum || liv.visit_i_quantity != i_qty_sum || liv.visit_e_quantity != e_qty_sum
        protocol = liv.arm.protocol.id
        arm = liv.arm.name
        service = liv.line_item.service.name

        r_qty_issue = liv.visit_r_quantity != r_qty_sum ? 'Y' : 'N'
        i_qty_issue = liv.visit_i_quantity != i_qty_sum ? 'Y' : 'N'
        e_qty_issue = liv.visit_e_quantity != e_qty_sum ? 'Y' : 'N'

        csv << [protocol, arm, service, liv.id, r_qty_issue, liv.visit_r_quantity, r_qty_sum, i_qty_issue, liv.visit_i_quantity, i_qty_sum, e_qty_issue, liv.visit_e_quantity, e_qty_sum]
      end
      bar.increment!
    end
  end
end
