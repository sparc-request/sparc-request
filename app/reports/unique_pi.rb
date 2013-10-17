class UniquePi < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################
  # example default options {MyClass => {:field_type => :select_tag, :field_label => "Something", :dependency => '#something_else_id', :dependency_id => "tables_uses_this_id'}
  # Key can be either string or ClassName
  # Value is hash of options
  # Options List #
  # :field_type => :select_tag, :radio_button_tag, :check_box_tag, :text_field_tag, :date_range
  # :field_label => key or optional text (default is key)
  # :dependency => id of data element that must be selected before this option is enabled
  # :dependency_id => default is dependency minus # but can be specified
  # :from => valid date, used with date range field_type, optional
  # :from_label => optional text (default is From)
  # :to => valid date, used with date range field_type, optional
  # :to_label => optional_text (default is To)
  # :for => specifies the date column this range is for
  def default_options
    {
      "Date Range" => {:field_type => :date_range, :for => "service_requests_submitted_at", :from => "2012-03-01".to_date, :to => Date.today},
      Institution => {:field_type => :select_tag},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
    }
  end

  # params are set during initialization
  # can be any method the primary table (defined in def table method) responds to
  def column_attrs
    attrs = {Institution => params[:institution_id], Provider => params[:provider_id], Program => params[:program_id], Core => params[:core_id], "Unique PI Last Name" => :last_name, "Unique PI First Name" => :first_name,
             "College" => :college, "Department" => :department}

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
    return :project_roles => {:protocol => {:service_requests => {:sub_service_requests => :organization}}}
  end

  # Conditions
  def where args={}
    organization_id = args[:core_id] || args[:program_id] || args[:provider_id] || args[:institution_id] # we want to go up the tree

    if args[:service_requests_submitted_at_from] and args[:service_requests_submitted_at_to]
      submitted_at = args[:service_requests_submitted_at_from].to_time.strftime("%Y-%m-%d 00:00:00")..args[:service_requests_submitted_at_to].to_time.strftime("%Y-%m-%d 23:59:59")
    end

    return :organizations => {:id => organization_id}, :project_roles => {:role => ['pi', 'primary-pi']}, :service_requests => {:submitted_at => submitted_at}
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
  
  ##################  BEGIN XLS EXPORT  #####################

  def to_xls

  end

  ##################   END XLS EXPORT   #####################

end
