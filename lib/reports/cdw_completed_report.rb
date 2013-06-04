class CdwCompletedReport < Report
  def self.description
  end

  def default_output_file
    return 'cdw_completed_report.xlsx'
  end

  def run
    header = [
      'SRID#',
      'Program',
      'Service',
      'Submitted Date',
      'Completed Date',
    ]

    service_names = [
      'MUSC Research Data Request (CDW)',
    ]

    # TODO: ideally I'd write this all with joins (would run faster),
    # but this is fine for now

    idx = 1

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'Report') do |sheet|
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

            if not protocol or not ssr then
              puts "Warning: bad line item #{li.inspect}"
              next
            end

            if ssr.status != 'complete' then
              # not complete, so skip this one
              next
            end

            row = [
              ssr.display_id,
              service.program.name,
              service.name,
              sr.submitted_at,
              li.complete_date,
            ]

            styles = [
              nil,
              nil,
              nil,
              nil,
              nil,
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

