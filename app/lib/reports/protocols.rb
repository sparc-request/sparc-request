# Copyright © 2011-2018 MUSC Foundation for Research Development
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

class ProtocolsReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Protocols"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      "Date Range" => {:field_type => :date_range, :for => "service_requests_original_submitted_date", :from => "2012-03-01".to_date, :to => Date.today},
      Institution => {:field_type => :select_tag, :has_dependencies => "true"},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      "Include Epic Interface Columns" => {:field_type => :check_box_tag, :for => 'show_epic_cols', :field_label => 'Include Epic Interface Columns'}
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["Protocol ID"] = "service_request.try(:protocol).try(:id)"
    attrs["Research Master ID"] = "service_request.try(:protocol).try(:research_master_id)"
    attrs["Protocol Short Title"] = "service_request.try(:protocol).try(:short_title)"
    attrs["Protocol Title"] = "service_request.try(:protocol).try(:title)"
    attrs["Number of Requests"] = "service_request.try(:protocol).try(:sub_service_requests).try(:count)"
    attrs["Funding Source"] = "service_request.try(:protocol).try(:funding_source)"
    attrs["Potential Funding Source"] = "service_request.try(:protocol).try(:potential_funding_source)"
    attrs["Sponsor Name"] = "service_request.try(:protocol).try(:sponsor_name)"
    attrs["Financial Account"] = "service_request.try(:protocol).try(:udak_project_number).try{prepend(' ')}"
    attrs["Study Phase"] = "service_request.try(:protocol).try{study_phases.map(&:phase).join(', ')}"

    attrs["NCT #"] = "service_request.try(:protocol).try(:human_subjects_info).try(:nct_number).try{prepend(' ')}"
    attrs["HR #"] = "service_request.try(:protocol).try(:human_subjects_info).try(:hr_number).try{prepend(' ')}"
    attrs["PRO #"] = "service_request.try(:protocol).try(:human_subjects_info).try(:pro_number).try{prepend(' ')}"
    attrs["IRB of Record"] = "service_request.try(:protocol).try(:human_subjects_info).try(:irb_of_record)"
    attrs["IRB Expiration Date"] = "service_request.try(:protocol).try(:human_subjects_info).try(:irb_expiration_date)"

    attrs["Primary PI Last Name"]   = "service_request.try(:protocol).try(:primary_principal_investigator).try(:last_name)"
    attrs["Primary PI First Name"]  = "service_request.try(:protocol).try(:primary_principal_investigator).try(:first_name)"
    attrs["Primary PI Email"]       = "service_request.try(:protocol).try(:primary_principal_investigator).try(:email)"
    attrs["Primary PI Institution"] = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'institution')"
    attrs["Primary PI College"]     = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'college')"
    attrs["Primary PI Department"]  = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'department')"
    attrs["Primary PI Division"]    = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'division')"

    attrs["Primary Coordinator(s)"] = "service_request.try(:protocol).try(:coordinators).try(:map, &:full_name).try(:join, ', ')"
    attrs["Primary Coordinator Email(s)"] = "service_request.try(:protocol).try(:coordinator_emails)"

    attrs["Business Manager(s)"] = "service_request.try(:protocol).try(:billing_managers).try(:map, &:full_name).try(:join, ', ')"
    attrs["Business Manager Email(s)"] = "service_request.try(:protocol).try(:billing_business_manager_email)"

    if params[:show_epic_cols]
      attrs["Selected For Epic"] = "service_request.try(:protocol).try(:selected_for_epic) ? 'Yes' : service_request.try(:protocol).try(:selected_for_epic).nil? ? '' : 'No'"
      attrs["Last Epic Push Date"] = "service_request.try(:protocol).try(:last_epic_push_time)"
      attrs["Last Epic Push Status"] = "service_request.try(:protocol).try(:last_epic_push_status)"
    end

    attrs
  end

  ################## END REPORT SETUP  #####################

  ################## BEGIN QUERY SETUP #####################
  # def table => primary table to query
  # includes, where, uniq, order, and group get passed to AR methods, http://apidock.com/rails/v3.2.13/ActiveRecord/QueryMethods
  # def includes => other tables to include
  # def where => conditions for query
  # def uniq => return distinct records
  # def group => group by this attribute (including table name is always a safe bet, ex. identities.id)
  # def order => order by these attributes (include table name is always a safe bet, ex. identities.id DESC, protocols.title ASC)
  # Primary table to query
  def table
    SubServiceRequest
  end

  # Other tables to include
  def includes
    return :organization, :service_request => {:line_items => :service}
  end

  # Conditions
  def where args={}
    organizations = Organization.all
    selected_organization_id = args[:core_id] || args[:program_id] || args[:provider_id] || args[:institution_id] # we want to go up the tree, service_organization_ids plural because we might have child organizations to include

    # get child organization that have services to related to them
    service_organization_ids = [selected_organization_id]
    if selected_organization_id
      org = Organization.find(selected_organization_id)
      service_organization_ids = org.all_child_organizations_with_self.map(&:id)
      service_organization_ids.flatten!
    end

    ssr_organization_ids = [args[:core_id], args[:program_id], args[:provider_id], args[:institution_id]].compact

    # get child organizations
    if not ssr_organization_ids.empty?
      org = Organization.find(selected_organization_id)
      ssr_organization_ids = [ssr_organization_ids, org.all_child_organizations_with_self.map(&:id)].flatten
    end

    if args[:service_requests_original_submitted_date_from] and args[:service_requests_original_submitted_date_to]
      submitted_at = args[:service_requests_original_submitted_date_from].to_time.strftime("%Y-%m-%d 00:00:00")..args[:service_requests_original_submitted_date_to].to_time.strftime("%Y-%m-%d 23:59:59")
    end

    # default values if none are provided
    service_organization_ids = Organization.all.map(&:id) if service_organization_ids.compact.empty? # use all if none are selected

    ssr_organization_ids = Organization.all.map(&:id) if ssr_organization_ids.compact.empty? # use all if none are selected

    submitted_at ||= self.default_options["Date Range"][:from]..self.default_options["Date Range"][:to]
    statuses = args[:status] || PermissibleValue.get_key_list('status') # use all if none are selected

    return :sub_service_requests => {:organization_id => ssr_organization_ids, :status => statuses}, :service_requests => {:submitted_at => submitted_at}, :services => {:organization_id => service_organization_ids}
  end

  # Return only uniq records for
  def uniq
  end

  def group
    "protocol_id"
  end

  def order
    "service_requests.original_submitted_date ASC"
  end

  ##################  END QUERY SETUP   #####################
end
