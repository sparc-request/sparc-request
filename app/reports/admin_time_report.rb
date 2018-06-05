# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class AdminTimeReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Admin Time"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      # "Date Range" => {:field_type => :date_range, :for => "service_requests_submitted_at", :from => "2012-03-01".to_date, :to => Date.today},
      Institution => {:field_type => :select_tag, :required => true, :has_dependencies => "true"},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id', :required => true},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id', :required => true},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      Service => {:field_type => :select_tag, :dependency => '#program_id, #core_id', :dependency_id => 'organization_id', :required => true},
      "Current Status" => {:field_type => :check_box_tag, :for => 'status', :multiple => PermissibleValue.get_hash('status')}
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["SRID"] = :display_id

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

    if params[:service_id]
      attrs[Service] = [params[:service_id], :name]
    end

    attrs["Service Request Status"] = :formatted_status

    attrs["Service Request Owner"] = "owner.try(:full_name)"

    attrs["Consult Arranged Date"] = "service_request.try(:consult_arranged_date).try(:strftime, \"%D\")"

    if params[:service_id]
      attrs["First Fulfillment Date"] = "line_items.where(service_id: #{params[:service_id]}).map(&:fulfillments).flatten.select(&:date?).sort_by(&:date).first.try(:date)"
      attrs["Last Fulfillment Date"] = "line_items.where(service_id: #{params[:service_id]}).map(&:fulfillments).flatten.select(&:date?).sort_by(&:date).last.try(:date)"

      attrs["Total Admin Time (minutes)"] = "line_items.where(service_id: #{params[:service_id]}).map(&:fulfillments).flatten.select{|fulfillment| fulfillment.timeframe == 'Min'}.sum{|x| x.time.to_i}"
      attrs["Total Admin Time (hours)"] = "line_items.where(service_id: #{params[:service_id]}).map(&:fulfillments).flatten.select{|fulfillment| fulfillment.timeframe == 'Hours'}.sum{|x| x.time.to_i}"

      attrs["Total Admin Time (each)"] = "line_items.where(service_id: #{params[:service_id]}).map(&:fulfillments).flatten.select{|fulfillment| fulfillment.timeframe == 'Each'}.sum{|x| x.time.to_i}"
      # attrs["Total Admin Time (blank)"] = "line_items.where(service_id: #{params[:service_id]}).map(&:fulfillments).flatten.select{|fulfillment| fulfillment.timeframe == nil}.sum(:time)"
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
    selected_organization_id = args[:core_id] || args[:program_id] || args[:provider_id] || args[:institution_id]

    ssr_organization_ids = [args[:core_id], args[:program_id], args[:provider_id], args[:institution_id]].compact

    # get child organizations
    if not ssr_organization_ids.empty?
      org = Organization.find(selected_organization_id)
      ssr_organization_ids = [ssr_organization_ids, org.all_child_organizations_with_self.map(&:id)].flatten
    end

    if args[:service_requests_submitted_at_from] and args[:service_requests_submitted_at_to]
      submitted_at = args[:service_requests_submitted_at_from].to_time.strftime("%Y-%m-%d 00:00:00")..args[:service_requests_submitted_at_to].to_time.strftime("%Y-%m-%d 23:59:59")
    end

    # default values if none are provided]
    ssr_organization_ids = Organization.all.map(&:id) if ssr_organization_ids.compact.empty? # use all if none are selected

    # submitted_at ||= self.default_options["Date Range"][:from]..self.default_options["Date Range"][:to]
    submitted_at = "2012-03-01".to_date..Date.today
    statuses = args[:status] || PermissibleValue.get_key_list('status') # use all if none are selected

    return :sub_service_requests => {:organization_id => ssr_organization_ids, :status => statuses}, :service_requests => {:submitted_at => submitted_at}, :services => {:id => args[:service_id]}
  end

  # Return only uniq records for
  def uniq
  end

  def group
  end

  def order
    "service_requests.submitted_at ASC"
  end

  ##################  END QUERY SETUP   #####################
end
