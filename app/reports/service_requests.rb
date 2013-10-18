class ServiceRequestsReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################
  
  def self.title
    "Service Requests"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      "Date Range" => {:field_type => :date_range, :for => "service_requests_submitted_at", :from => "2012-03-01".to_date, :to => Date.today},
      Institution => {:field_type => :select_tag},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      "Current Status" => {:field_type => :check_box_tag, :for => 'status', :multiple => AVAILABLE_STATUSES},
    }
  end

  # see app/reports/test_report.rb for all options
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

    attrs["SRID"] = :display_id
    attrs["Date Submitted"] = "service_request.submitted_at.strftime('%Y-%m-%d')"

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
    return :project_roles => {:protocol => {:service_requests => {:line_items => :service, :sub_service_requests => :organization}}}
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
    end

    ssr_organization_ids = [args[:core_id], args[:program_id], args[:provider_id], args[:institution_id]].compact

    # get child organizations that have process_ssr
    if not ssr_organization_ids.empty?
      org = Organization.find(selected_organization_id)
      ssr_organization_ids = [ssr_organization_ids, org.all_children.select{|x| x.process_ssrs?}.map(&:id)].flatten
    end

    if args[:service_requests_submitted_at_from] and args[:service_requests_submitted_at_to]
      submitted_at = args[:service_requests_submitted_at_from].to_time.strftime("%Y-%m-%d 00:00:00")..args[:service_requests_submitted_at_to].to_time.strftime("%Y-%m-%d 23:59:59")
    end

    # default values if none are provided
    service_organization_ids = Organization.all.map(&:id) if service_organization_ids.compact.empty? # use all if none are selected
    ssr_organization_ids = Organization.all.map(&:id) if ssr_organization_ids.compact.empty? # use all if none are selected
    submitted_at ||= self.default_options["Date Range"][:from]..self.default_options["Date Range"][:to]
    statuses = args[:status] || AVAILABLE_STATUSES.keys # use all if none are selected

    return :sub_service_requests => {:organization_id => ssr_organization_ids, :status => statuses}, :service_requests => {:submitted_at => submitted_at}, :services => {:organization_id => service_organization_ids}
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
