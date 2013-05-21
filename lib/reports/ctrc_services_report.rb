require 'csv'

class CtrcServicesReport < Report
  def run
    CSV.open('./ctrc_services_report.csv', 'wb') do |csv|
      # Column Headers
      csv << ['Core',
              'Service',
              'True Rate',
              'College Department',
              'Federal',
              'Foundation/Organization',
              'Industry-Initiated/Industry-Sponsored',
              'Investigator-Initiated/Industry-Sponsored',
              'Internal Funded Pilot Project']

      # Get all CTRC organizations
      ctrcs = Organization.all.select {|x| x.tags.map(&:name).include?('ctrc')}
      ctrcs.each do |ctrc|
        if ctrc.cores
          ctrc.cores.each do |core|
            core.services.each do |service|
              row = []
              row << service.organization.name
              row << service.name
              row << service.displayed_pricing_map.full_rate.to_f / 100.0
              row << find_applicable_rate(service, 'college') / 100.0
              row << find_applicable_rate(service, 'federal') / 100.0
              row << find_applicable_rate(service, 'foundation') / 100.0
              row << find_applicable_rate(service, 'industry') / 100.0
              row << find_applicable_rate(service, 'investigator') / 100.0
              row << find_applicable_rate(service, 'internal') / 100.0

              csv << row
            end
          end
        end
      end
    end
  end

  def find_applicable_rate service, funding_source
    pricing_map = service.displayed_pricing_map
    pricing_setup = service.organization.current_pricing_setup
    selected_rate_type = pricing_setup.rate_type(funding_source)
    applied_percentage = pricing_setup.applied_percentage(selected_rate_type)
    rate = pricing_map.applicable_rate(selected_rate_type, applied_percentage)
    return rate
  end
end

