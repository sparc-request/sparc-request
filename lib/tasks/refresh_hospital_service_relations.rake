# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

desc "Destroying all service relations on hospital services"
task :refresh_hospital_service_relations => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  # Get linked services on hospital services: services where send_to_epic is true and cpt_code is not nil
  hospital_service_relations = ServiceRelation.where(service_id: Service.where(send_to_epic: 1).where.not(cpt_code: nil).pluck(:id))
  continue = prompt("Are you sure you want to destroy #{hospital_service_relations.count} service relations on hospital services? (Y/n): ")
  if (continue == 'y') || (continue == 'Y')
    ActiveRecord::Base.transaction do
      puts "Destroying #{hospital_service_relations.count} service relations#{hospital_service_relations.count > 100 ? ', this may take a few moments' : ''}..."
      hospital_service_relations.destroy_all

      # Update service relations with update_related_services
      Rake::Task["update_related_services"].invoke
    end
  else
    puts "Exiting rake task..."
  end

end
