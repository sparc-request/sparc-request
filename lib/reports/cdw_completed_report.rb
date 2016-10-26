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

