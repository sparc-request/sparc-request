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
  desc "Import rates frm DHHS rate file"
  task :import_dhhs_rates => :environment do
    begin
      #### import dhhs rates,  CSV format should be From,Thru,Amount,ORG ID
      next_version = RevenueCodeRange.maximum('version').to_i+1

      CSV.foreach(ENV['rate_file'], :headers => true) do |row|
        from = row['From'].strip[0..3].to_i
        thru = row['Thru'].strip[0..3].to_i
        percentage = row['Amount'].to_f
        org_id = row['ORG ID'].to_i

        puts "Revenue code range for organization #{org_id} is #{from} to #{thru} at #{percentage}%"
    
        RevenueCodeRange.create :from => from, :to => thru, :percentage => percentage, :applied_org_id => org_id, :vendor => 'dhhs', :version => next_version
      end
    rescue Exception => e
      puts "Usage: rake data:import_dhhs_rates rate_file=tmp/rate_file.csv"
      puts e.message
    end
  end
end
