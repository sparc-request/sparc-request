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

class ShortInteractionsReport < ReportingModule
  $canned_reports << name unless ($canned_reports.include? name)   # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################
  
  def self.title
    "Short Interactions"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      "Created Date Range" => {:field_type => :date_range, :for => "short_interaction_created_at", :from => "2012-03-01".to_date, :to => Date.today},
      Institution => {:field_type => :select_tag, :has_dependencies => "true"},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}
    attrs["Service Provider"] = "identity.full_name"
    attrs["Provider/Program (First Available)"] = "self.identity.display_available_provider_program_name"
    attrs["Date Entered"] = "self.created_at.try(:strftime, \"%Y-%m-%d\")"
    attrs["Subject of Interaction"] = :display_subject
    attrs["Type of Interaction"] =  :display_interaction_type
    attrs["Duration in minutes"] = :duration_in_minutes
    attrs["Investigator Name"] = :name
    attrs["Investigator Email"] = :email
    attrs["Investigator Institution"] = :institution
    attrs["Notes"] = :note
    
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
    ShortInteraction
  end

  # Other tables to include
  def includes
    return :identity => {:service_providers => :organization}
  end

  # Conditions
  def where args={}
    fdate = args[:short_interaction_created_at_from].nil? ? self.default_options["Created Date Range"][:from].to_time.strftime("%Y-%m-%d 00:00:00") : args[:short_interaction_created_at_from].to_time.strftime("%Y-%m-%d 00:00:00")
    tdate = args[:short_interaction_created_at_to].nil? ? self.default_options["Created Date Range"][:to].to_time.strftime("%Y-%m-%d 23:59:59")  : args[:short_interaction_created_at_to].to_time.strftime("%Y-%m-%d 23:59:59") 
    created_at = fdate..tdate

    organizations = Organization.all
    selected_organization_id = args[:program_id] || args[:provider_id] || args[:institution_id] # we want to go up the tree, service_organization_ids plural because we might have child organizations to include

    # get child organization that have services to related to them
    service_organization_ids = [selected_organization_id]
    if selected_organization_id
      org = Organization.find(selected_organization_id)
      service_organization_ids = org.all_child_organizations_with_self.pluck(:id)
      service_organization_ids.flatten.uniq
    end


    # default values if nothing is selected
    service_organization_ids = Organization.all.map(&:id) if service_organization_ids.compact.empty? # use all if nothing is selected

    if selected_organization_id
      return :created_at => created_at, :service_providers => {:organization_id => service_organization_ids} 
    else
      return :created_at => created_at
    end
  end

  # Return only uniq records for
  def uniq
  end

  def group
  end

  def order
    "short_interactions.created_at DESC"
  end

  ##################  END QUERY SETUP   #####################
end