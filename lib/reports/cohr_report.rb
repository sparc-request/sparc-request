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

  def initialize
    super()
    @from_date = nil
    @to_date = nil
  end

  def add_options(opts)
    super(opts)
    opts.on('-f', '--from DATE') { |d| @from_date = d }
    opts.on('-t', '--to DATE')   { |d| @to_date = d }
  end

  def run
    header = [
      'PI',
      'Requested by',
      'SRID#',
      'Status',
      'Service',
      'Submitted date',
      'Completed date',
      'Minutes',
      'Hours',
      'Price per Hour',
      'Total Cost',
    ]

    service_names = [
      'Unassisted microCT usage',
      'microCT scanning/analysis',
      'Digital imaging and analysis',
      'Unassisted microscope imaging',
    ]

    # TODO: ideally I'd write this all with joins (would run faster),
    # but this is fine for now

    idx = 1

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'Report') do |sheet|
        currency = sheet.styles.add_style(format_code: '####.##')

        sheet.add_row(header)
        idx += 1

        service_names.each do |service_name|
          service = Service.find_by_name(service_name)

          if not service then
            puts "No service for #{service_name}"
            next
          end

          line_items = LineItem.where('service_id = ?', service.id)

          line_items.each do |li|
            ssr = li.sub_service_request
            sr = li.service_request
            protocol = sr.protocol

            # complete_date = li.complete_date
            # next if not complete_date
            # next if @from_date and complete_date < @from_date
            # next if @to_date   and complete_date > @to_date

            if not protocol or not ssr then
              puts "Warning: bad line item #{li.inspect}"
              next
            end

            if not li.units_per_package then
              puts "Warning: no units per quantity for line item #{li.inspect}"
              next
            end

            # TODO: what do I do if there is more than one PI?
            pi = protocol.project_roles.find_by_role('pi')
            pi_name = pi.try(:identity).try(:full_name)
            requester = sr.service_requester.full_name
            srid = ssr.display_id
            service = li.service.name
            packages = (li.quantity.to_f / li.units_per_package.to_f).ceil # TODO: only works for one-time-fee
            minutes = packages * li.units_per_package
            price_per_minute = li.applicable_rate / li.units_per_package # TODO: need to use units_per_quantity?
            total_cost = li.direct_costs_for_one_time_fee

            row = [
              pi_name,
              requester,
              srid,
              ssr.status,
              service,
              sr.submitted_at,
              li.complete_date,
              minutes,
              "=F#{idx}/60",
              price_per_minute * 60 / 100.0,
              total_cost / 100.0,
            ]

            styles = [
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              nil,
              currency,
              currency,
            ]

            res = sheet.add_row(row, style: styles)
            idx += 1
          end
        end
      end
      p.serialize(@output_file)
    end
  end
end

