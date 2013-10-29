# Report that displays all SUCCESS Center Service Requests By core

class SuccessReport < Report

  def self.description
    "Provide a list of all service requests, by core, under the SUCCESS Center."
  end

  def default_output_file
    "#{Time.now.strftime('%F')}_success_report.xlsx"
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
      'SRID #',
      'SUCCESS Center Core',
      'Date Submitted',
      'Status'
    ]

    statuses = AVAILABLE_STATUSES

    orgs = Program.find(47).cores.map(&:id)

    ssrs = SubServiceRequest.select {|x| orgs.include?(x.organization_id)}.sort_by {|y| y.organization_id}

    idx = 1

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'Report') do |sheet|
        idx += 1

        ssrs.each do |ssr|
          submitted_date = ssr.service_request.submitted_at

          # next if not orgs.include?(ssr.organization_id)
          next if not submitted_date
          next if @from_date and submitted_date < Date.parse(@from_date)
          next if @to_date   and submitted_date > Date.parse(@to_date)

          row = [
            ssr.display_id,
            ssr.organization.name,
            submitted_date.strftime("%D"),
            statuses[ssr.status]
          ]

          res = sheet.add_row(row)
          idx += 1
        end
      end
      p.serialize(@output_file)
    end
  end

end