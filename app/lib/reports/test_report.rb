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

class TestReport < ReportingModule
  #$canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Test Report"
  end

  # example default options {MyClass => {:field_type => :select_tag, :field_label => "Something", :dependency => '#something_else_id', :dependency_id => "tables_uses_this_id'}
  # Key can be either string or ClassName
  # Value is hash of options
  # Options List #
  # :field_type => :select_tag, :radio_button_tag, :check_box_tag, :text_field_tag, :date_range, :date_field
  # :field_label => key or optional text (default is key)
  # :required => boolean (default if false)
  # :dependency => id of data element that must be selected before this option is enabled
  # :dependency_id => default is dependency minus # but can be specified
  # :from => valid date, used with date range field_type, optional
  # :from_label => optional text (default is From)
  # :to => valid date, used with date range field_type, optional
  # :to_label => optional_text (default is To)
  # :for => specifies the name of the field (used to generate name attribute, if not specified the name is inferred from the Key)
  # :multiple => method, string representation of method chain, hash
  # :grouping => hash representation used to group checkboxes {"Active" => ['submitted', 'in_process'], "Other" => ['draft']}
  # :selected => array of pre-selected checkboxes ['submitted', 'in_process']
  # :custom_name_method => method (default is :name)
  # :has_dependencies => this is used to signal the first dependencies to set up on page load. For example, institution when filter organizations.
  # :selectpicker => this adds the class of 'selectpicker' onto the item, for usage by the selectpicker dropdown js.
  def default_options
    {
      "Date Range" => {:field_type => :date_range, :for => "service_requests_submitted_at", :from => "2012-03-01".to_date, :to => Date.today, :required => true},
      Institution => {:field_type => :select_tag, :required => true, :has_dependencies => "true"},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      "Current Status" => {:field_type => :check_box_tag, :for => 'status', :multiple => PermissibleValue.get_hash('status')},
      "One Date" => {:field_type => :date_field, :for => "service_requests_submitted_at"}
    }
  end

  # params are set during initialization
  # can be any method the primary table (defined in def table method) responds to
  # attrs = {model or string => [id or method, conversion]}
  # example attrs = {Institution => [params[:institution_id], :abbreviation], "College" => [:college, COLLEGES]}
  def column_attrs
    attrs = {}

    if params[:institution_id]
      attrs[Institution] = [params[:institution_id], :abbreviation]
    end

    if params[:provider_id]
      attrs[Provider] = [params[:provider_id], :abbreviation]
    end

    if params[:program_id]
      attrs[Program] = [params[:program_id], :abbreviation]
    end

    if params[:core_id]
      attrs[Core] = [params[:core_id], :abbreviation]
    end

    attrs["Unique PI Last Name"] = :last_name
    attrs["Unique PI First Name"] = :first_name
    attrs["Institution"] = "try(:professional_org_lookup, 'institution')"
    attrs["College"]     = "try(:professional_org_lookup, 'college')"
    attrs["Department"]  = "try(:professional_org_lookup, 'department')"
    attrs["Division"]    = "try(:professional_org_lookup, 'division')"

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
    Identity
  end

  # Other tables to include
  def includes
    return :project_roles => {:protocol => {:service_requests => {:line_items => :service, :sub_service_requests => :organization}}}
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

    if args[:service_requests_submitted_at_from] and args[:service_requests_submitted_at_to]
      submitted_at = args[:service_requests_submitted_at_from].to_time.strftime("%Y-%m-%d 00:00:00")..args[:service_requests_submitted_at_to].to_time.strftime("%Y-%m-%d 23:59:59")
    end

    # default values if none are provided
    service_organization_ids = Organization.all.map(&:id) if service_organization_ids.compact.empty? # use all if none are selected
    ssr_organization_ids = Organization.all.map(&:id) if ssr_organization_ids.compact.empty? # use all if none are selected
    submitted_at ||= self.default_options["Date Range"][:from]..self.default_options["Date Range"][:to]
    statuses = args[:status] || PermissibleValue.get_key_list('status') # use all if none are selected

    return :sub_service_requests => {:organization_id => ssr_organization_ids, :status => statuses}, :project_roles => {:role => ['pi', 'primary-pi']}, :service_requests => {:submitted_at => submitted_at}, :services => {:organization_id => service_organization_ids}
  end

  # Return only uniq records for
  def uniq
    :identity
  end

  def group
  end

  def order
  end

  ##################  END QUERY SETUP   #####################
end
