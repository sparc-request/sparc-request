# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Report for all services under the REDCap core
# Monthly report

class RedcapReport < Report
  def self.description
    "Provide a list of Services submitted within specified dates under the REDCap Core."
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
              if li.sub_service_request.past_statuses.where(:status => 'submitted').count > 0 or ssr.status == 'submitted'
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