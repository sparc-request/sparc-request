# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

module V1

  class Shallow < Grape::Entity
    expose  :id, as: :sparc_id
    expose  :remote_service_callback_url, as: :callback_url
    
    format_with(:iso_timestamp) { |dt| dt ? dt.iso8601 : nil }
  end

  class ArmShallow < Shallow
    root 'arms', 'arm'
  end

  class ClinicalProviderShallow < Shallow
    root 'clinical_providers', 'clinical_provider'
  end

  class HumanSubjectsInfoShallow < Shallow
    root 'human_subjects_info', 'human_subjects_info'
  end

  class IdentityShallow < Shallow
    root 'identities', 'identity'
  end

  class LineItemShallow < Shallow
    root 'line_items', 'line_item'
  end

  class LineItemsVisitShallow < Shallow
    root 'line_items_visits', 'line_items_visit'
  end

  class ProcessSsrsOrganizationShallow < Shallow
    root 'process_ssrs_organizations', 'process_ssrs_organization'
  end

  class ProjectRoleShallow < Shallow
    root 'project_roles', 'project_role'
  end

  class ProtocolShallow < Shallow
    root 'protocols', 'protocol'
  end

  class ProjectShallow < ProtocolShallow
    root 'protocols', 'protocol'
  end

  class ServiceShallow < Shallow
    root 'services', 'service'
  end

  class ServiceRequestShallow < Shallow
    root 'service_requests', 'service_request'
  end

  class StudyShallow < ProtocolShallow
    root 'protocols', 'protocol'
  end

  class SubServiceRequestShallow < Shallow
    root 'sub_service_requests', 'sub_service_request'
  end

  class VisitGroupShallow < Shallow
    root 'visit_groups', 'visit_group'
  end

  class VisitShallow < Shallow
    root 'visits', 'visit'
  end
end
