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

require 'csv'

namespace :data do
  task add_service_to_studies: :environment do
    STDOUT.puts " "
    STDOUT.puts "*****This is a task to add a service to a given set of studies*****"
    STDOUT.puts "You will first be asked to enter in the service to be added."
    STDOUT.puts "Will you be entering in the Serivce 'ID' or Service 'NAME' to get started? (Enter ID or NAME)"
    
    service_input_type = STDIN.gets.strip.downcase
    
    while !(service_input_type == 'id' || service_input_type == 'name') do
      STDOUT.puts " "
      STDOUT.puts "Unrecognized Input"
      STDOUT.puts "Will you be entering in the Serivce 'ID' or Service 'NAME' to get started? (Enter ID or NAME)"
      service_input_type = STDIN.gets.strip
    end

    service = nil
    service_search_attempted = false
    
    while !service
      if service_search_attempted == true
        STDOUT.puts " "
        STDOUT.puts "Unable to find service.  Please try again."
      end
      STDOUT.puts " "
      STDOUT.puts "Please enter in the service #{service_input_type}."

      service_input_details = STDIN.gets.strip

      if service_input_type == 'id'
        service_search_attempted = true
        service = Service.find_by_id(service_input_details)
      elsif service_input_type == 'name'
        service_search_attempted = true
        service = Service.where(name: service_input_details).first
      end
    end

    STDOUT.puts "Next, will you be entering in the Organization 'ID' or Organization 'NAME' to decide what organization should be attached to the service request? (Enter ID or NAME)"
    
    organization_input_type = STDIN.gets.strip.downcase
    
    while !(organization_input_type == 'id' || organization_input_type == 'name') do
      STDOUT.puts " "
      STDOUT.puts "Unrecognized Input"
      STDOUT.puts "Will you be entering in the Organization 'ID' or Organization 'NAME' to decide what organization should be attached to the service request? (Enter ID or NAME)"
      organization_input_type = STDIN.gets.strip
    end

    organization = nil 
    organization_search_attempted = false

    while !organization
      if organization_search_attempted == true
        STDOUT.puts " "
        STDOUT.puts "Unable to find organization.  Please try again."
      end
      STDOUT.puts " "
      STDOUT.puts "Please enter in the organization #{organization_input_type}."

      organization_input_details = STDIN.gets.strip

      if organization_input_type == 'id'
        organization_search_attempted = true
        organization = Organization.find_by_id(organization_input_details)
      elsif organization_input_type == 'name'
        organization_search_attempted = true
        organization = Organization.where(name: organization_input_details).first
      end
    end

    STDOUT.puts " "
    STDOUT.puts "Now, please upload a csv file with the ids for the protocols that need this service attached to them (NOTE:  You *must* include the full path to the relevant file for upload)."

    file_path = STDIN.gets.strip
    protocols_csv = CSV.read(file_path, headers: true)

    while !protocols_csv
      STDOUT.puts " "
      STDOUT.puts "Unrecognized Input"
      STDOUT.puts "Please upload a csv file with the ids for the protocols that need this service attached to them (NOTE:  You *must* include the full path to the relevant file for upload)."
      protocols_csv = CSV.read(file_path, headers: true)
    end

    protocols = []
    protocols_csv.each do |row|
      protocols << row.to_hash
    end


    STDOUT.puts " "
    STDOUT.puts "WORKING..."

    # The following is, in fact, an n+1 query and a terrible practice but was the best possible compromise at the time for acknowledging that the list of user entered values may contain an id that does not exist in the database.  If a better  method is found in the future, please replace this loop.
    invalid_ids = []
    valid_ids = 0
    protocols.each do |protocol|
      id = protocol["Protocol ID"].to_i
      protocol = Protocol.find_by_id(id)

      if protocol
        valid_ids += 1
        sr = protocol.service_requests.create(status: "complete")
        ssr = sr.sub_service_requests.create(organization: organization, status: "complete")
      else
        invalid_ids << id
        STDOUT.puts "Unable to find Protocol #{id}"
      end
    end

    STDOUT.puts " "
    STDOUT.puts "#{valid_ids} protocols had service '#{service.name.strip}' added successfully from organization '#{organization.name.strip}'!"
    if invalid_ids.present?
      STDOUT.puts "The following protocol ids could not be found.  Please run this task again after confirm the correct ids for these protocols:"
      STDOUT.puts "#{invalid_ids}"
    end
  end
end
