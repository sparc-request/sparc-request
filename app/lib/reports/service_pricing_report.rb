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

class ServicePricingReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Service Pricing"
  end

  def default_options
    {
      "Pricing Date"  =>  { :field_type => :date_field, :for => "services_pricing_date"},
      Institution     =>  { :field_type => :select_tag, :required => true, :has_dependencies => "true"},
      Provider        =>  { :field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program         =>  { :field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core            =>  { :field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      ## commented out to remove tags, but will likely be added in later ##
      # "Tags"          =>  { :field_type => :check_box_tag, :for => 'tags',
      #                       :multiple => Tag.to_hash,
      #                       :selected => Tag.to_hash.values
      #                     },
      "Rate Types"    =>  { :field_type => :check_box_tag, :for => "rate_types",
                            :multiple => {
                              "full_rate" => "Service Rate",
                              "federal_rate" => "Federal Rate",
                              "corporate_rate" => "Corporate Rate",
                              "other_rate" => "Other Rate",
                              "member_rate" => "Member Rate" },
                            :selected => ['Service Rate', 'Federal Rate', 'Corporate Rate', 'Other Rate', 'Member Rate']
                          },
      "Additional Codes" => { :field_type => :check_box_tag, :for => "additional_codes",
                              :multiple => {
                                "cpt_code" => "CPT Code",
                                "revenue_code" => "Revenue Code",
                                "order_code" => "Order Code",
                                "eap_id" => "EAP ID"}
                            }
    }
  end

  def records
    ## commented out to remove tags, but will likely be added in later ##
    # records ||= self.table.joins(self.joins(self.params)).where(self.where(self.params)).group(self.group).order(self.order).distinct(self.uniq)
    records ||= self.table.eager_load(:pricing_maps).where(self.where(self.params)).group(self.group).order(self.order).distinct(self.uniq)
  end

  def column_attrs
    attrs = {}

    if params[:institution_id]
      attrs[Institution] = [params[:institution_id], :abbreviation]
    else
      attrs["Institution"] = "parents.select{|org| org.type == 'Institution'}.first.try(:abbreviation)"
    end

    if params[:provider_id]
      attrs[Provider] = [params[:provider_id], :abbreviation]
    else
      attrs["Provider"] = "parents.select{|org| org.type == 'Provider'}.first.try(:abbreviation)"
    end

    if params[:program_id]
      attrs[Program] = [params[:program_id], :abbreviation]
    else
      attrs["Program"] = "parents.select{|org| org.type == 'Program'}.first.try(:abbreviation)"
    end

    if params[:core_id]
      attrs[Core] = [params[:core_id], :abbreviation]
    else
      attrs["Core"] = "parents.select{|org| org.type == 'Core'}.first.try(:abbreviation)"
    end

    attrs["Service"] = :name

    attrs["Service Status"] = :humanized_status

    if params[:additional_codes]
      if params[:additional_codes].include?("cpt_code")
        attrs["CPT Code"] = "cpt_code"
      end

      if params[:additional_codes].include?("revenue_code")
        attrs["Revenue Code"] = "revenue_code"
      end

      if params[:additional_codes].include?("order_code")
        attrs["Order Code"] = "order_code"
      end

      if params[:additional_codes].include?("eap_id")
        attrs["EAP ID"] = "eap_id"
      end
    end

    if params[:rate_types]
      if params[:rate_types].include?("full_rate")
        attrs["Full Rate"] = "report_pricing(pricing_map_for_date(\"#{params[:services_pricing_date]}\").full_rate.to_f) rescue 'N/A'"
      end

      if params[:rate_types].include?("federal_rate")
        attrs["Federal Rate"] = "report_pricing(pricing_map_for_date(\"#{params[:services_pricing_date]}\").true_rate_hash(\"#{params[:services_pricing_date]}\", Organization.find(organization_id))[:federal]) rescue 'N/A'"
      end

      if params[:rate_types].include?("corporate_rate")
        attrs["Corporate Rate"] = "report_pricing(pricing_map_for_date(\"#{params[:services_pricing_date]}\").true_rate_hash(\"#{params[:services_pricing_date]}\", Organization.find(organization_id))[:corporate]) rescue 'N/A'"
      end

      if params[:rate_types].include?("other_rate")
        attrs["Other Rate"] = "report_pricing(pricing_map_for_date(\"#{params[:services_pricing_date]}\").true_rate_hash(\"#{params[:services_pricing_date]}\", Organization.find(organization_id))[:other]) rescue 'N/A'"
      end

      if params[:rate_types].include?("member_rate")
        attrs["Member Rate"] = "report_pricing(pricing_map_for_date(\"#{params[:services_pricing_date]}\").true_rate_hash(\"#{params[:services_pricing_date]}\", Organization.find(organization_id))[:member]) rescue 'N/A'"
      end

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
    Service
  end

  # Other tables to include
  def includes
  end

  ## commented out to remove tags, but will likely be added in later ##
  # def joins args={}
  #   rtn = [:pricing_maps]
  #   rtn << :tags if args[:tags]
  #   return rtn
  # end

  # Conditions
  def where args={}
    selected_organization_id = args[:core_id] || args[:program_id] || args[:provider_id] || args[:institution_id] # we want to go up the tree, service_organization_ids plural because we might have child organizations to include

    # get child organization that have services to related to them
    service_organization_ids = [selected_organization_id]
    if selected_organization_id
      organizations = Organization.all
      org = Organization.find(selected_organization_id)
      service_organization_ids = org.all_child_organizations_with_self.map(&:id)
      service_organization_ids.flatten!
      service_organization_ids.uniq!
    end

    service_organization_ids = Organization.ids if service_organization_ids.compact.empty? # use all if none are selected

    service_organizations = Organization.where(id: service_organization_ids)

    date = args[:services_pricing_date] ? Date.strptime(args[:services_pricing_date], "%m/%d/%Y") : Date.today
    query = "`pricing_maps`.`display_date` <= '#{date}' and `services`.`organization_id` IN (#{service_organization_ids.join(',')})"
    ## commented out to remove tags, but will likely be added in later ##
    return query # + (args[:tags] ? " and tags.name IN (\"#{args[:tags].join('\",\"')}\")" : "")
  end

  def uniq
  end

  def group
  end

  def order
  end

  ##################  END QUERY SETUP   #####################
end
