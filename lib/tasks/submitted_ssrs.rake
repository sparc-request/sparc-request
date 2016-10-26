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

# OK - here's what I need - the number of service requests SUMITTED between 1/1/15 and 2/28/15 for all of SCTR.
# This means either at the program or at the core level. So if the program doesn't have any cores, you'd run the
# report at the program level (like Biostatistics). If the program has cores, you'd run at the core level
# (like the SUCCESS Center). I only need those requests that were submitted...so it doesn't matter if they are now
# in a different status (ex: In Process, Complete, etc.) Is that hard? Doable? I need the SRID, the SCTR Program,
# the Core (if applicable), the Primary PI, The PI College, the PI Department, and the submitted date.
# Protocol Title and date the SSR was completed (if applicable)

namespace :data do
  desc "List services rendered and their costs"
  task :submitted_ssrs => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    # start_date = prompt "Enter the starting date (2014-01-01): "
    # end_date   = prompt "Enter the ending date (2014-01-01): "
    start_date = '2015-10-01'
    end_date = '2015-10-31'

    CSV.open("tmp/submitted_ssrs_#{start_date}_to_#{end_date}.csv","wb") do |csv|
      csv << ["Protocol Title", "SRID", "Program/Core", "Completed Date", "Primary PI", "PI College", "PI Department", "Submitted Date"]

      ssr_ids = PastStatus.where("status = 'submitted' and date between '#{start_date}' and '#{end_date}'").pluck(:sub_service_request_id).uniq
      ssrs = SubServiceRequest.where("id in (#{ssr_ids.join(',')}) and org_tree_display like '%SCTR%'")
      ssrs.each do |ssr|
        protocol = ssr.service_request.protocol
        title = protocol.title
        srid = ssr.display_id
        org_tree = ssr.org_tree_display
        completed_date = AuditRecovery.where("auditable_id = #{ssr.id} and auditable_type = 'SubServiceRequest' and audited_changes like '%\n- complete%' and created_at between '#{start_date}' and '#{end_date}'").first.try(:created_at)
        primary_pi = protocol.primary_principal_investigator
        name = primary_pi.full_name
        college = primary_pi.college
        department = primary_pi.department
        submitted_date = PastStatus.where("status = 'submitted' and sub_service_request_id = #{ssr.id} and date between '#{start_date}' and '#{end_date}'").first.date
        csv << [title, srid, org_tree, completed_date, name, college, department, submitted_date]
      end
    end
  end
end
