require 'active_record'
require 'mysql2'
require 'csv'
require 'pp'


def fix_old_codes
  ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',
    :database => 'sparc_reporting'
  )

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

def generate_report
  ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',
    :database => 'sparc_reporting'
  )

  CSV.open('./apr_reporting.csv', 'wb') do |csv|
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