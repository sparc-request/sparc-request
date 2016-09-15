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

task :completed_procedures => :environment do

  def prompt(*args)
      print(*args)
      STDIN.gets.strip
  end
  
  puts ""
  puts ""
  puts "This task will display all completed procedures for all services under an organization."
  org_id = prompt ("Enter the organization id: ").to_i

  completed_procedures = Procedure.where(:completed => true)
  services = Service.where(:organization_id => org_id)
  service_ids = services.map(&:id)
  procedures_for_services = []

  completed_procedures.each do |procedure|
    if procedure.service.present?
      if service_ids.include?(procedure.service_id)
        procedures_for_services << procedure
      end
    elsif procedure.line_item.present?
      if service_ids.include?(procedure.line_item.service_id)
        procedures_for_services << procedure
      end
    end
  end

  grouped = procedures_for_services.group_by(&:direct_service)
  grouped.each do |service, procedures|
    puts "For #{service.name} we have #{procedures.count} completed procedures."
  end

end