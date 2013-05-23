# From the pivotal tracker story:
#
#   We need a report for the COHR. Attached is a sample of the report
#   that needs to be created (with real studies). We need to pull the
#   PI, SRID#, services, price per hour, and total cost from the Admin
#   Portal and calculate the number of hours (minutes/60). Use only
#   studies with either of the four services, Unassisted microCT usage,
#   microCT scanning/analysis, Digital imaging and analysis, and
#   Unassisted microscope imaging. They are located under the
#   Mineralized Tissue Facility core. 
#
class CohrReport < Report
  def self.description
    "uses PI, srid, services, price per hour, and total cost to calculate the number of hours"
  end

  def default_output_file
    return 'cohr_report.xlsx'
  end

  def run
    header = [
      'PI',
      'Requested by',
      'SRID#',
      'Service',
      'Minutes',
      'Hours',
      'Price per Hour',
      'Total Cost'
    ]

    service_names = [
      'Unassisted microCT usage',
      'microCT scanning/analysis',
      'Digital imaging and analysis',
      'Unassisted microscopy imaging',
    ]

    # TODO: ideally I'd write this all with joins (would run faster),
    # but this is fine for now
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'Report') do |sheet|
        sheet.add_row(header)

        service_names.each do |service_name|
          service = Service.find_by_name(service_name)

          if not service then
            puts "No service for #{service_name}"
            next
          end

          line_items = LineItem.where('service_id = ?', service.id)

          line_items.each_with_index do |li, idx|
            ssr = li.sub_service_request
            sr = li.service_request
            protocol = sr.protocol

            if not protocol or not ssr then
              puts "Warning: bad line item #{li.inspect}"
              next
            end

            # TODO: what do I do if there is more than one PI?
            pi = protocol.project_roles.find_by_role('pi')
            pi_name = pi ? pi.identity.full_name : ''
            requester = sr.service_requester.full_name
            srid = ssr.display_id
            service = li.service.name
            minutes = li.quantity # TODO: only works for one-time-fee
            price_per_minute = li.per_unit_cost
            total_cost = li.direct_costs_for_one_time_fee

            row = [
              pi_name,
              requester,
              srid,
              service,
              minutes,
              "=E#{idx+2}/60",
              price_per_minute * 60,
              total_cost,
            ]

            res = sheet.add_row(row)
          end
        end
      end
      p.serialize(@output_file)
    end
  end
end

