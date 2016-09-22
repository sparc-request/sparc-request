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

require 'active_record'
require 'mysql2'
require 'csv'
require 'pp'

class AprReport < Report
  def fix_old_codes
    # ActiveRecord::Base.establish_connection(
    #   :adapter => 'mysql2',
    #   :host => 'localhost',
    #   :database => 'sparc_reporting'
    # )

    # Assemble activity codes hash
    @activity_codes = {}
    CSV.foreach("../../Desktop/activity_codes.csv") do |row|
      @activity_codes["#{row[0]}"] = row[1]
    end

    # Assemble organization codes hash
    @phs = {}
    @non_phs = {}
    CSV.foreach('../../Desktop/organizations.csv') do |row|
      case row[3]
      when "phs"
        @phs["#{row[0]}"] = row[1]
      when "non-phs"
        @non_phs["#{row[0]}"] = row[1]
      else
      end
    end

    Protocol.all.each do |protocol|
      protocol.federal_grant_code_id = @activity_codes["#{protocol.federal_grant_code_id}"] if @activity_codes.include? protocol.federal_grant_code_id
      protocol.federal_phs_sponsor = @phs["#{protocol.federal_phs_sponsor}"] if @phs.include? protocol.federal_phs_sponsor
      protocol.federal_non_phs_sponsor = @non_phs["#{protocol.federal_non_phs_sponsor}"] if @non_phs.include? protocol.federal_non_phs_sponsor
      protocol.save
    end
  end

  def service_and_ssr_counts
    # ActiveRecord::Base.establish_connection(
    #   :adapter => 'mysql2',
    #   :host => 'localhost',
    #   :database => 'sparc_reporting'
    # )

    CSV.open('./service_and_ssr_counts.csv', 'wb') do |csv|
      # Column headers
      csv << ['Organization', 'Services Requested (with process_ssrs)', 'Services Requested (without process_ssrs)', 'Sub Service Requests']
      array = []

      Organization.all.each do |organization|
        ssrs = SubServiceRequest.find_all_by_organization_id(organization.id)
        ssrs_with_sr = ssrs.select {|x| x.service_request}
        ssrs_with_protocol = ssrs_with_sr.select {|x| x.service_request.protocol}
        ssrs_with_status = ssrs_with_protocol.select {|x| ['submitted', 'in process', 'complete'].include?(x.status)}
        within_dates = ssrs_with_status.select {|x| relevant_date(x) < Date.parse('2013-01-01') && relevant_date(x) > Date.parse('2012-03-01')}
        line_items = within_dates.map {|x| x.line_items.count}.inject(:+)

        lis = LineItem.all.select {|x| x.service.organization_id == organization.id}
        lis_with_ssr = lis.select {|x| x.sub_service_request}
        lis_with_sr = lis_with_ssr.select {|x| x.sub_service_request.service_request}
        lis_with_protocol = lis_with_sr.select {|x| x.sub_service_request.service_request.protocol}
        lis_with_status = lis_with_protocol.select {|x| ['submitted', 'in process', 'complete'].include?(x.sub_service_request.status)}
        lis_within_dates = lis_with_status.select {|x| relevant_date(x.sub_service_request) < Date.parse('2013-01-01') && relevant_date(x.sub_service_request) > Date.parse('2012-03-01')}

        csv << [organization.name, line_items, lis_within_dates.count, within_dates.count]
      end
    end

  end

  def relevant_date ssr
    ssr.service_request.submitted_at.nil? ? ssr.created_at : ssr.service_request.submitted_at
  end

  def default_output_file
    return './apr_reporting.csv'
  end

  def run
    # ActiveRecord::Base.establish_connection(
    #   :adapter => 'mysql2',
    #   :host => 'localhost',
    #   :database => 'sparc_reporting'
    # )

    CSV.open(output_file, 'wb') do |csv|
      # Column headers
      csv << ['Protocol ID',
              'PI Last Name',
              'PI First Name',
              'PI Email',
              'PI Institution',
              'PI College',
              'PI Department',
              'PI Subspecialty Code',
              'Short Title',
              'Title',
              'Funding Status',
              'If Funded, Funding Source',
              'If Federal, Federal Grant Code',
              'If Federal, Federal PHS Sponsor',
              'If Federal, Federal Non-PHS Sponsor',
              'If Federal, Federal Grant Serial Number',
              'Human Subjects (Y/N)',
              'HR#',
              'PRO#',
              'IRB Approval Date',
              'Vertebrate Animals (Y/N)',
              'IACUC#',
              'IACUC Approval Date',
              'IND (Y/N)',
              'IND#',
              'IND On Hold (Y/N)',
              'IDE (Y/N)',
              'Organizational Entities Selected for Request']

      # Iterate over protocol data
      Protocol.all.each do |protocol|
        # Initialize empty row
        row = []
        row << protocol.id.to_s

        # Get the PI
        pi = protocol.principal_investigators.first
        # PI Information
        if pi
          row << pi.last_name
          row << pi.first_name
          row << pi.email
          row << (INSTITUTIONS.detect {|k,v| v == pi.institution}[0] rescue pi.institution)
          row << (COLLEGES.detect {|k,v| v == pi.college}[0] rescue pi.college)
          row << (DEPARTMENTS.detect {|k,v| v == pi.department}[0] rescue pi.department)
          row << (SUBSPECIALTIES.detect {|k,v| v == pi.subspecialty}[0] rescue pi.subspecialty)
        else
          7.times do
            row << ''
          end
        end

        # Protocol Information
        row << protocol.short_title
        row << protocol.title
        row << protocol.funding_status.try(:humanize)
        row << (protocol.funding_status == 'funded' ? protocol.funding_source : '').try(:humanize)
        
        row << (protocol.funding_source == 'federal' ? protocol.federal_grant_code_id : '')
        row << (protocol.funding_source == 'federal' ? protocol.federal_phs_sponsor : '')
        row << (protocol.funding_source == 'federal' ? protocol.federal_non_phs_sponsor : '')
        row << (protocol.funding_source == 'federal' ? protocol.federal_grant_serial_number : '')

        row << (protocol.research_types_info.human_subjects ? 'Yes' : 'No')
        if protocol.research_types_info.human_subjects
          row << (protocol.research_types_info.human_subjects ? protocol.human_subjects_info.hr_number : '')
          row << (protocol.research_types_info.human_subjects ? protocol.human_subjects_info.pro_number : '')
          row << (protocol.research_types_info.human_subjects ? protocol.human_subjects_info.irb_approval_date.try(:strftime, "%F") : '')
        else
          3.times do
            row << ''
          end
        end

        row << (protocol.research_types_info.vertebrate_animals ? 'Yes' : 'No')
        if protocol.research_types_info.vertebrate_animals
          row << (protocol.research_types_info.vertebrate_animals ? protocol.vertebrate_animals_info.iacuc_number : '')
          row << (protocol.research_types_info.vertebrate_animals ? protocol.vertebrate_animals_info.iacuc_approval_date.try(:strftime, "%F") : '')
        else
          2.times do
            row << ''
          end
        end

        row << (protocol.research_types_info.investigational_products ? 'Yes' : 'No')
        if protocol.research_types_info.investigational_products
          row << (protocol.research_types_info.investigational_products ? protocol.investigational_products_info.ind_number : '')
          row << (protocol.research_types_info.investigational_products ? (protocol.investigational_products_info.ind_on_hold ? 'Yes' : 'No') : '')
        else
          2.times do
            row << ''
          end
        end

        row << (protocol.research_types_info.ip_patents ? 'Yes' : 'No')

        # Get all Service Request Organizations
        organizations = []
        protocol.service_requests.each do |service_request|
          service_request.sub_service_requests.each do |ssr|
            organizations << ssr.organization.name
          end
        end

        row << (organizations.empty? ? '' : organizations.join("\n"))

        csv << row
      end
    end
  end
end

