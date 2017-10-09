
class SPARCAccountReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################
  
  def self.title
    "SPARC Account"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    { 
       "Created Date Range" => {:field_type => :date_range, :for => "created_at", :from => "2012-03-01".to_date, :to => Time.current},
       "Account Status" => {:field_type => :check_box_tag, :for => 'approved', :multiple => {1 => "Active/Approved", 0 => "Deactivated"},
                            :selected => ["Active/Approved"]},
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["Last Name"] = :last_name
    attrs["First Name"] = :first_name
    attrs["Email"] = :email
    attrs["Institution"] = "try(:professional_org_lookup, 'institution')"
    attrs["College"] = "try(:professional_org_lookup, 'college')"
    attrs["Department"] = "try(:professional_org_lookup, 'department')"
    attrs["Account Created Date"] = "self.created_at.try(:strftime, \"%D\")"
    attrs["ID"] = :id
    attrs["LDAP_UID"] = :ldap_uid
    attrs["Approved/Activated?"] = "self.approved? ? \"Y\" : \"N\""
    attrs["Overlord?"] = "self.catalog_overlord? ? \"Y\" : \"N\""

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
  end

  # Conditions
  def where args={}
    fdate = args[:created_at_from].nil? ? self.default_options["Created Date Range"][:from].to_time.strftime("%Y-%m-%d 00:00:00") : args[:created_at_from].to_time.strftime("%Y-%m-%d 00:00:00")
    tdate = args[:created_at_to].nil? ? self.default_options["Created Date Range"][:to].to_time.strftime("%Y-%m-%d 23:59:59")  : args[:created_at_to].to_time.strftime("%Y-%m-%d 23:59:59") 
    created_at = fdate..tdate
    statuses = args[:approved] || [1, 0]
    return {:created_at => created_at, :approved => statuses}
  end

  # Return only uniq records for
  def uniq
  end

  def group
  end

  def order
    "approved DESC, created_at DESC"
  end

  ##################  END QUERY SETUP   #####################
end
