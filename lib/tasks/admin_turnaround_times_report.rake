# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
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