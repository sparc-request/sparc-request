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

# Report that displays all service requests in the system with PIs and requesters

class AllServiceRequestsReport < Report
  def self.description
    "Provide a list of all service requests with their corresponding PIs and requesters."
  end

  def default_output_file
    return "#{Time.now.strftime('%F')}_all_service_requests_report.xlsx"
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
      'Submitted Date',
      'Requester',
      'Requester Department',
      'Primary Investigator',
      'Primary Investigator Department'
    ]

    statuses = AVAILABLE_STATUSES

    idx = 1

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'Report') do |sheet|
        sheet.add_row(header)
        idx += 1

        SubServiceRequest.all.each do |ssr|
          sr = ssr.service_request
          protocol = sr.protocol
          submitted_date = sr.submitted_at

          next if not submitted_date
          next if @from_date and submitted_date < Date.parse(@from_date)
          next if @to_date   and submitted_date > Date.parse(@to_date)

          if not protocol then
            puts "Warning: Bad Service Request #{protocol.inspect}"
            next
          end

          requester = sr.service_requester
          pi = protocol.principal_investigators.first
          srid = ssr.display_id

          row = [
            srid,
            submitted_date.strftime("%D"),
            requester.try(:full_name),
            requester.try(:department),
            pi.try(:full_name),
            pi.try(:department)
          ]

          res = sheet.add_row(row)
          idx += 1
        end
      end
      p.serialize(@output_file)  
    end
  end
end