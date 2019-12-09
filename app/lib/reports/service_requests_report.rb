# Copyright © 2011-2019 MUSC Foundation for Research Development
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

class ServiceRequestsReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Service Requests"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      "Submission Date Range" => {:field_type => :date_range, :for => "submitted_at", :from => "2012-03-01".to_date, :to => Date.today},
      Institution => {:field_type => :select_tag, :has_dependencies => "true"},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      "Tags" => {:field_type => :text_field_tag},
      "Current Status" => {:field_type => :check_box_tag, :for => 'status', :multiple => PermissibleValue.get_hash('status')},
      "Show APR Data" => {:field_type => :check_box_tag, :for => 'apr_data', :multiple => {"irb" => "IRB", "iacuc" => "IACUC"}},
      "Show SPARCFulfillment Information" => {:field_type => :check_box_tag, :for => 'fulfillment_info', :field_label => 'Show SPARCFulfillment Information' }
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["SRID"] = :display_id
    attrs["RMID"] = "service_request.try(:protocol).try(:research_master_id)" if Setting.get_value("research_master_enabled")
    attrs["Date Submitted"] = "submitted_at.strftime('%Y-%m-%d')"
    attrs["Status"] = :formatted_status

    attrs["Protocol Short Title"] = "service_request.try(:protocol).try(:short_title)"
    attrs["Full Protocol Title"] = "service_request.try(:protocol).try(:title)"


    if params[:institution_id]
      attrs[Institution] = [params[:institution_id], :abbreviation]
    else
      attrs["Institution"] = "org_tree.select{|org| org.type == 'Institution'}.first.try(:abbreviation)"
    end

    if params[:provider_id]
      attrs[Provider] = [params[:provider_id], :abbreviation]
    else
      attrs["Provider"] = "org_tree.select{|org| org.type == 'Provider'}.first.try(:abbreviation)"
    end

    if params[:program_id]
      attrs[Program] = [params[:program_id], :abbreviation]
    else
      attrs["Program"] = "org_tree.select{|org| org.type == 'Program'}.first.try(:abbreviation)"
    end

    if params[:core_id]
      attrs[Core] = [params[:core_id], :abbreviation]
    else
      attrs["Core"] = "org_tree.select{|org| org.type == 'Core'}.first.try(:abbreviation)"
    end

    attrs["Primary PI Last Name"]         = "service_request.try(:protocol).try(:primary_principal_investigator).try(:last_name)"
    attrs["Primary PI First Name"]        = "service_request.try(:protocol).try(:primary_principal_investigator).try(:first_name)"
    attrs["Primary PI Institution"]       = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'institution')"
    attrs["Primary PI College"]           = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'college')"
    attrs["Primary PI Department"]        = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'department')"
    attrs["Primary PI Division"]          = "service_request.try(:protocol).try(:primary_principal_investigator).try(:professional_org_lookup, 'division')"
    attrs["Primary Coordinator(s)"]       = "service_request.try(:protocol).try(:coordinators).try(:map, &:full_name).try(:join, ', ')"
    attrs["Primary Coordinator Email(s)"] = "service_request.try(:protocol).try(:coordinator_emails)"

    if params[:apr_data]
      if params[:apr_data].include?("irb")
        attrs["IRB Checked Y/N"] = "service_request.try(:protocol).try(:research_types_info).try(:human_subjects) ? \"Y\" : \"N\""
        attrs["If true, PRO #)"] = "service_request.try(:protocol).try(:human_subjects_info).try(:pro_number)"
        attrs["IRB Approval Date"] = "service_request.try(:protocol).try(:human_subjects_info).try(:irb_approval_date).try(:strftime, \"%D\")"
        attrs["IRB Expiration Date"] = "service_request.try(:protocol).try(:human_subjects_info).try(:irb_expiration_date).try(:strftime, \"%D\")"
      end
      if params[:apr_data].include?("iacuc")
        attrs["IACUC Checked Y/N"] = "service_request.try(:protocol).try(:research_types_info).try(:vertebrate_animals) ? \"Y\" : \"N\""
        attrs["If true, IACUC #"] = "service_request.try(:protocol).try(:vertebrate_animals_info).try(:iacuc_number)"
        attrs["IACUC Approval Date"] = "service_request.try(:protocol).try(:vertebrate_animals_info).try(:iacuc_approval_date).try(:strftime, \"%D\")"
        attrs["IACUC Expiration Date"] = "service_request.try(:protocol).try(:vertebrate_animals_info).try(:iacuc_expiration_date).try(:strftime, \"%D\")"
      end
    end

    if params[:fulfillment_info]
      attrs["Sent to SPARCFulfillment"] = "in_work_fulfillment ? 'Yes' : 'No'"
    end

    attrs["Owner"] = '"#{owner.try(:first_name)} #{owner.try(:last_name)}"'

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

    if args[:tags]
      tags = args[:tags].split(',')
    else
      tags = []
    end

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

    if args[:submitted_at_from] and args[:submitted_at_to]
      submitted_at = DateTime.strptime(args[:submitted_at_from], "%m/%d/%Y").to_s(:db)..DateTime.strptime(args[:submitted_at_to], "%m/%d/%Y").strftime("%Y-%m-%d 23:59:59")
    end

    # default values if none are provided
    service_organization_ids = Organization.all.map(&:id) if service_organization_ids.compact.empty? # use all if none are selected

    service_organizations = Organization.find(service_organization_ids)

    unless tags.empty?
      tagged_organization_ids = service_organizations.reject {|x| (x.tags.map(&:name) & tags).empty?}.map(&:id)
      service_organization_ids = service_organization_ids.reject {|x| !tagged_organization_ids.include?(x)}
    end

    ssr_organization_ids = Organization.all.map(&:id) if ssr_organization_ids.compact.empty? # use all if none are selected

    submitted_at ||= self.default_options["Submission Date Range"][:from]..self.default_options["Submission Date Range"][:to]
    statuses = args[:status] || PermissibleValue.get_key_list('status') # use all if none are selected

    return :sub_service_requests => {:organization_id => ssr_organization_ids, :status => statuses, :submitted_at => submitted_at}, :services => {:organization_id => service_organization_ids}
  end

  # Return only uniq records for
  def uniq
  end

  def group
  end

  def order
    "sub_service_requests.submitted_at ASC"
  end

  ##################  END QUERY SETUP   #####################
end
