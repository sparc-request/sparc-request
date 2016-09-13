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
  desc "Create CSV report of all one time fee line items under a given provider"
  task :turnaround_times_report => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def get_user_provider_input
      providers = Organization.where(:type => "provider")

      puts ""
      puts "ID        Name"
      puts ""

      providers.each do |org|
        puts "#{org.id}".rjust(2) + "        " + "#{org.name}"
      end

      puts ""
      puts ""
      provider_id = prompt("Please enter one of the above provider ids you would like to run the report for: ")

      provider_id
    end

    def full_ssr_id(ssr)
    protocol = ssr.service_request.protocol

    "#{protocol.id}-#{ssr.ssr_id}"
    end

    def extract_status_dates ssr
      statuses = ssr.past_statuses
      dates = [ssr.service_request.submitted_at.try(:to_date), statuses.last.created_at.try(:to_date)]

      dates
    end

    def build_turnaround_report(csv, ssr, provider, program, core)
      if ssr.service_request.protocol && (ssr.organization_id == core.id) && (ssr.created_at.to_date > 2012-03-01)
        past_statuses = ssr.past_status_lookup
        dates = extract_status_dates(ssr)
        pi = ssr.service_request.protocol.try(:primary_principal_investigator).try(:full_name)
        owner = ssr.owner_id ? Identity.find(ssr.owner_id).full_name : ""

        row = [ssr.service_request.protocol.id, full_ssr_id(ssr), ssr.service_request.protocol.short_title, pi, provider.abbreviation, program.abbreviation, core.abbreviation, owner, dates[0], dates[1]]
        csv << row
      end
    end

    provider_id = get_user_provider_input
    ssrs = SubServiceRequest.where(:status => "complete")
    unless provider_id.blank?
      provider = Organization.find(provider_id)

      CSV.open("tmp/#{Date.today}_#{provider.abbreviation}_turnaround_times_report.csv", "wb") do |csv|
        row = ["PID", "SRID", "Short Title", "PI", "Provider", "Program", "Core", "Service Request Owner", "Date Submitted", "Date Completed"]
        csv << row

        provider.programs.each do |program|
          program.cores.each do |core|
            ssrs.each do |ssr|
              build_turnaround_report(csv, ssr, provider, program, core)
            end
          end
        end
      end
    else
      puts "No provider id specified."
    end
  end
end