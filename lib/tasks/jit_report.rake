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

desc 'JIT report'
task :jit_report => :environment do
  ssrs = SubServiceRequest.where(:organization_id => 14, :status => 'ctrc_approved')

  CSV.open("tmp/jit_report.csv", "w+") do |csv|
    csv << ['Original Submit At Date', 'SPARC ID', 'Provider/Program', 'Primary PI', 'Title', 'Name of IRB', 'IRB # (either HR# or Pro#)', 'Date of most recent IRB approval']

    ssrs.each do |ssr|
      first_submit = ssr.past_statuses.where(:status => 'submitted').first.date
      protocol = ssr.service_request.protocol
      human_subjects_info = protocol.human_subjects_info
      csv << [first_submit.strftime('%m/%d/%y'), ssr.display_id, ssr.organization.name, protocol.primary_principal_investigator.display_name,
        protocol.title, human_subjects_info.irb_of_record, human_subjects_info.irb_and_pro_numbers, (human_subjects_info.irb_approval_date.strftime('%m/%d/%y') rescue nil)]
    end
  end
end
