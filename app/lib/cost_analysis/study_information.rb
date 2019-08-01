module CostAnalysis
  class StudyInformation
  
    ## display_funding_source
    include Dashboard::ProjectsHelper

    HEADERS = {
      :protocol_number => "CRU Protocol #",
      :enrollment_period => "Enrollment Period",
      :short_title => "Short Title",
      :study_title => "Study Title",
      :funding_source => "Funding Source",
      :target_entrollment => "Target Enrollment"
    }

    attr_accessor :protocol_number, :enrollment_period, :short_title, :study_title, :funding_source, :target_enrollment, :contacts

    def initialize(protocol)
      @protocol_number = protocol.id
      @enrollment_period = "#{protocol.start_date.strftime("%m/%d/%Y")} - #{protocol.end_date.strftime("%m/%d/%Y")}"
      @short_title = protocol.short_title
      @study_title = protocol.title
      @funding_source = "#{protocol.sponsor_name} (#{display_funding_source(protocol)})"
      @target_enrollment = ""
      
      @contacts = protocol.project_roles.map do |au|
        ProjectContact.new(au.role, au.identity.full_name, au.identity.email)
      end
    end

    def header_for(field)
      HEADERS[field]
    end

    def primary_investigators
      @contacts.select{ |c| c.pi?}
    end

    def additional_contacts
      @contacts - primary_investigators
    end
  end
end
