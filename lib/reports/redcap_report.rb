# Report for all services under the REDCap core
# Monthly report

class RedcapReport < Report
  def self.description
    "Proived a list of Services submitted within specified dates under the REDCap Core."
  end

  def default_output_file
    return "#{Time.now.strftime('%F')}_REDCap_Report.xlsx"
  end

  def initialize
    super
    @from_date = nil
    @to_date = nil
  end

  def add_options opts
    super(opts)
    opts.on('-f', '--from DATE') { |d| @from_date = d }
    opts.on('-t', '--to DATE')   { |d| @to_date = d }
  end

  def run
    header = [
      'Submitted Date',
      'Service',
      'Requester',
      'E-mail',
      'SRID #',
      'Status',
      'Service Provider'
    ]

    statuses = AVAILABLE_STATUSES

    idx = 1

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'Report') do |sheet|
        sheet.add_row(header)
        idx += 1

        Organization.find_by_name('REDCap Services').services.each do |service|
          line_items = LineItem.where('service_id = ?', service.id)

          line_items.each do |li|
            ssr = li.sub_service_request
            sr = li.service_request
            protocol = sr.protocol

            if ssr
              if li.sub_service_request.past_statuses.where(:status => 'submitted').count > 0
                submitted_date = li.sub_service_request.service_request.submitted_at
                next if not submitted_date
                next if @from_date and submitted_date < Date.parse(@from_date)
                next if @to_date   and submitted_date > Date.parse(@to_date)

                if not protocol or not ssr then
                  puts "Warning: Bad line item #{li.inspect}"
                  next
                end

                requester = sr.service_requester
                srid = ssr.display_id
                service = li.service.name
                status = statuses[ssr.status]
                provider = ssr.owner.full_name

                row = [
                  submitted_date.strftime("%D"),
                  service,
                  requester.full_name,
                  requester.email,
                  srid,
                  status,
                  provider
                ]

                res = sheet.add_row(row)
                idx += 1
              end
            end
          end
        end
      end
      p.serialize(@output_file)  
    end
  end
end