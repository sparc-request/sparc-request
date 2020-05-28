# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

module CostAnalysis
  class StudyInformation
  
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
      @funding_source = "#{protocol.sponsor_name} (#{protocol.display_funding_source_value})"
      @target_enrollment = ""
      
      @contacts = protocol.project_roles.map do |au|
        ProjectContact.new(au.role, au.identity.full_name, au.identity.email)

      end
    end

    def header_for(field)

      if field == :protocol_number
        I18n.t 'activerecord.attributes.protocol.id'
      else
        HEADERS[field]
      end
    end

    def primary_investigators
      @contacts.select{ |c| c.pi?}
    end

    def additional_contacts
      @contacts - primary_investigators
    end
  end
end
