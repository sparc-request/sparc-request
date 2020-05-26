# Copyright © 2011-2020 MUSC Foundation for Research Development
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
      "Include Epic Interface Columns" => {:field_type => :check_box_tag, :for => 'show_epic_cols', :field_label => 'Include Epic Interface Columns'},
      "Include Investigational Device Columns" => { field_type: :check_box_tag, for: 'show_device_cols', field_label: "Include Investigational Device Columns" }
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["Protocol ID"]                  = "id"
    attrs["Research Master ID"]           = "research_master_id"
    attrs["Protocol Short Title"]         = "short_title"
    attrs["Protocol Title"]               = "title"
    attrs["Number of Requests"]           = "sub_service_requests.length"
    attrs["Funding Source"]               = "funding_source.present? ? PermissibleValue.get_value('funding_source', funding_source) : ''"
    attrs["Potential Funding Source"]     = "potential_funding_source.present? ? PermissibleValue.get_value('potential_funding_source', potential_funding_source) : ''"
    attrs["Sponsor Name"]                 = "sponsor_name"
    attrs["Financial Account"]            = "udak_project_number.try{prepend(' ')}"

    attrs["NCT #"]                        = "human_subjects_info.try(:nct_number).try{prepend(' ')}"
    attrs["PRO #"]                        = "irb_records.first.try(:pro_number).try{prepend(' ')}"
    attrs["IRB of Record"]                = "irb_records.first.try(:irb_of_record)"
    attrs["Study Phase"]                  = "irb_records.first.try{study_phases.map(&:phase).join(', ')}"
    attrs["IRB Expiration Date"]          = "irb_records.first.try(:irb_expiration_date).try(:strftime, '%D')"

    attrs["Primary PI Last Name"]         = "primary_pi.try(:last_name)"
    attrs["Primary PI First Name"]        = "primary_pi.try(:first_name)"
    attrs["Primary PI Email"]             = "primary_pi.try(:email)"
    attrs["Primary PI Institution"]       = "primary_pi.try(:professional_org_lookup, 'institution')"
    attrs["Primary PI College"]           = "primary_pi.try(:professional_org_lookup, 'college')"
    attrs["Primary PI Department"]        = "primary_pi.try(:professional_org_lookup, 'department')"
    attrs["Primary PI Division"]          = "primary_pi.try(:professional_org_lookup, 'division')"

    attrs["Primary Coordinator(s)"]       = "coordinators.try{map(&:full_name)}.try(:join, ', ')"
    attrs["Primary Coordinator Email(s)"] = "coordinator_emails"

    attrs["Business Manager(s)"]          = "billing_managers.try(:map, &:full_name).try(:join, ', ')"
    attrs["Business Manager Email(s)"]    = ":billing_business_manager_email"

    if params[:show_epic_cols]
      attrs["Selected For Epic"]          = "selected_for_epic ? 'Yes' : selected_for_epic.nil? ? '' : 'No'"
      attrs["Last Epic Push Date"]        = "last_epic_push_time"
      attrs["Last Epic Push Status"]      = "last_epic_push_status"
    end

    if params[:show_device_cols]
      attrs["IND #"]                      = "investigational_products_info.try(:ind_number)"
      attrs["IDE/HDE/HUD Type"]           = "investigational_products_info.try(:exemption_type).present? ? PermissibleValue.get_value('product_exemption_type', investigational_products_info.try(:exemption_type)) : ''"
      attrs["IDE/HDE/HUD #"]              = "investigational_products_info.try(:inv_device_number)"
    end

    attrs
  end

  ################## END REPORT SETUP  #####################

  ################## BEGIN QUERY SETUP #####################
  # def table => primary table to query
  # includes, preload, where, uniq, order, and group get passed to AR methods, http://apidock.com/rails/v3.2.13/ActiveRecord/QueryMethods
  # def includes => other tables to include for where queries
  # def preload => other tables to eager load
  # def where => conditions for query
  # def uniq => return distinct records
  # def group => group by this attribute (including table name is always a safe bet, ex. identities.id)
  # def order => order by these attributes (include table name is always a safe bet, ex. identities.id DESC, protocols.title ASC)
  # Primary table to query
  def table
    Protocol
  end

  # Other tables to include
  def includes
    [:service_requests, sub_service_requests: { line_items: :service }]
  end

  # Other tables to prload
  def preload
    [:billing_managers, :coordinators, :human_subjects_info, :investigational_products_info, irb_records: :study_phases, primary_pi: { professional_organization: { parent: { parent: :parent } } }]
  end

  # Conditions
  def where args={}
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
    if ssr_organization_ids.any?
      org = Organization.find(selected_organization_id)
      ssr_organization_ids = [ssr_organization_ids, org.all_child_organizations_with_self.map(&:id)].flatten
    end

    if args[:service_requests_original_submitted_date_from] and args[:service_requests_original_submitted_date_to]
      submitted_at = DateTime.strptime(args[:service_requests_original_submitted_date_from], "%m/%d/%Y").to_s(:db)..DateTime.strptime(args[:service_requests_original_submitted_date_to], "%m/%d/%Y").strftime("%Y-%m-%d 23:59:59")
    end

    query             = { service_requests: { submitted_at: submitted_at } }
    query[:services]  = { organization_id: service_organization_ids } if service_organization_ids.any?

    if ssr_organization_ids.any? || args[:status]
      query[:sub_service_requests] = {}
      query[:sub_service_requests][:organization_id]  = ssr_organization_ids if ssr_organization_ids.any?
      query[:sub_service_requests][:status]           = args[:status] if args[:status]
    end

    return query
  end

  # Return only uniq records for
  def uniq
  end

  def group
  end

  def order
    "service_requests.original_submitted_date ASC"
  end

  ##################  END QUERY SETUP   #####################
end
