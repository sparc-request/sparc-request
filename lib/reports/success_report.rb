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