class ServicePricingReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Service Pricing"
  end

  def default_options
    {
      "Pricing Date" => {:field_type => :date_field, :for => "services_pricing_date"},
      Institution => {:field_type => :select_tag, :required => true},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      "Tags" => {:field_type => :text_field_tag},
      "Rate Types" => {:field_type => :check_box_tag, :for => "rate_types",
                      :multiple => {"full_rate" => "Service Rate",
                                    "federal_rate" => "Federal Rate",
                                    "corporate_rate" => "Corporate Rate",
                                    "other_rate" => "Other Rate",
                                    "member_rate" => "Member Rate"}
                     }
    }
  end

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

    attrs["Service"] = :name

    if params[:full_rate]
      attrs["Full Rate"] = "displayed_pricing_map(params[:services_pricing_date]).full_rate"
    end

    if params[:federal_rate]

    end

    if params[:corporate_rate]

    end

    if params[:_rate]

    end
    if params[:federal_rate]

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
    return :pricing_maps
  end

  # Conditions
  def where args={}
    selected_organization_id = args[:core_id] || args[:program_id] || args[:provider_id] || args[:institution_id] # we want to go up the tree, service_organization_ids plural because we might have child organizations to include

    # get child organization that have services to related to them
    service_organization_ids = [selected_organization_id]
    if selected_organization_id
      org = Organization.find(selected_organization_id)
      service_organization_ids += org.all_children.map(&:id)
      service_organization_ids.flatten!
      service_organization_ids.uniq!
    end

    service_organization_ids = Organization.all.map(&:id) if service_organization_ids.compact.empty? # use all if none are selected

    return :services => {:organization_id => service_organization_ids}

  end

  def uniq
    :identity
  end

  def group
  end

  def order
  end

  ##################  END QUERY SETUP   #####################
end