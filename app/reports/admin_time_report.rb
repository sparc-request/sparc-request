class AdminTimeReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Admin Time"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      Institution => {:field_type => :select_tag},
      Provider => {:field_type => :select_tag, :dependency => '#institution_id', :dependency_id => 'parent_id'},
      Program => {:field_type => :select_tag, :dependency => '#provider_id', :dependency_id => 'parent_id'},
      Core => {:field_type => :select_tag, :dependency => '#program_id', :dependency_id => 'parent_id'},
      Service => {:field_type => :select_tag, :dependency => '#core_id', :dependency_id => 'organization_id'},
      "Current Status" => {:field_type => :check_box_tag, :for => 'status', :multiple => AVAILABLE_STATUSES}
      # "Tags" => {:field_type => :text_field_tag},
      # "Show APR Data" => {:field_type => :check_box_tag, :for => 'apr_data', :multiple => {"irb" => "IRB", "iacuc" => "IACUC"}}
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}
    attrs["User ID"] = :user_id
    attrs["User Name"] = "identity.try(:full_name)"
    attrs["Submitted Date"] = "completed_at.try(:strftime, \"%D\")"



    # if params[:survey_id]
    #   survey = Survey.find(params[:survey_id])
    #   survey.sections.each do |section|
    #     section.questions.each do |question|
    #       question.answers.each do |answer|
    #         if answer.response_class == "text"
    #           attrs[ActionView::Base.full_sanitizer.sanitize(question.text)] = "responses.select{|response| response.question_id == #{question.id}}.first.try(:text_value)"
    #         else
    #           attrs[ActionView::Base.full_sanitizer.sanitize(question.text)] = "responses.select{|response| response.question_id == #{question.id}}.first.try(:answer).try(:text)"
    #         end
    #       end
    #     end
    #   end
    # end

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

    # get child organization that have services to related to them
    service_organization_ids = [selected_organization_id]
    if selected_organization_id
      org = Organization.find(selected_organization_id)
      service_organization_ids += org.all_children(organizations).map(&:id)
      service_organization_ids.flatten!
    end

    ssr_organization_ids = [args[:core_id], args[:program_id], args[:provider_id], args[:institution_id]].compact

    # get child organizations
    if not ssr_organization_ids.empty?
      org = Organization.find(selected_organization_id)
      ssr_organization_ids = [ssr_organization_ids, org.all_children(organizations).map(&:id)].flatten
    end

    # default values if none are provided
    service_organization_ids = Organization.all.map(&:id) if service_organization_ids.compact.empty? # use all if none are selected

    service_organizations = Organization.find(service_organization_ids)

    ssr_organization_ids = Organization.all.map(&:id) if ssr_organization_ids.compact.empty? # use all if none are selected

    statuses = args[:status] || AVAILABLE_STATUSES.keys # use all if none are selected

    return :sub_service_requests => {:organization_id => ssr_organization_ids, :status => statuses}, :services => {:organization_id => service_organization_ids}
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
