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

  class ArmFullWithShallowReflection < ArmFull
    root 'arms', 'arm'

    expose :protocol,           using: V1::ProtocolShallow
    expose :line_items_visits,  using: V1::LineItemsVisitShallow
    expose :visit_groups,       using: V1::VisitGroupShallow
  end

  class IdentityFullWithShallowReflection < IdentityFull
    root 'identities', 'identity'
    expose :protocols, using: V1::ProtocolShallow
  end
  
  class HumanSubjectsInfoFullWithShallowReflection < HumanSubjectsInfoFull
    root 'human_subjects_infos', 'human_subjects_info'

    expose :protocol, using: V1::ProtocolShallow
  end

  class ClinicalProviderFullWithShallowReflection < ClinicalProviderFull
    root 'clinical_providers', 'clinical_provider'

    expose :identity,     using: V1::IdentityShallow
    expose :organization, using: V1::ProcessSsrsOrganizationShallow
  end

  class ProjectRoleFullWithShallowReflection < ProjectRoleFull
    root 'project_roles', 'project_role'

    expose :protocol, using: V1::ProtocolShallow
    expose :identity, using: V1::IdentityShallow
  end

  class ProtocolFullWithShallowReflection < ProtocolFull
    root 'protocols', 'protocol'

    expose :arms,                using: V1::ArmShallow
    expose :service_requests,    using: V1::ServiceRequestShallow
    expose :project_roles,       using: V1::ProjectRoleShallow
    expose :human_subjects_info, using: V1::HumanSubjectsInfoShallow
  end

  class ProjectFullWithShallowReflection < ProtocolFullWithShallowReflection
    root 'protocols', 'protocol'
  end

  class LineItemFullWithShallowReflection < LineItemFull
    root 'line_items', 'line_item'

    expose :service,              using: V1::ServiceShallow
    expose :service_request,      using: V1::ServiceRequestShallow
    expose :sub_service_request,  using: V1::SubServiceRequestShallow
    expose :line_items_visits,    using: V1::LineItemsVisitShallow
  end

  class LineItemsVisitFullWithShallowReflection < LineItemsVisitFull
    root 'line_items_visits', 'line_items_visit'

    expose :line_item, using: V1::LineItemShallow
    expose :arm,       using: V1::ArmShallow
    expose :visits,    using: V1::VisitShallow
  end

  class ServiceFullWithShallowReflection < ServiceFull
    root 'services', 'service'

    expose :line_items, using: V1::LineItemShallow
  end

  class ServiceRequestFullWithShallowReflection < ServiceRequestFull
    root 'service_requests', 'service_request'

    expose :protocol,             using: V1::ProtocolShallow
    expose :line_items,           using: V1::LineItemShallow
    expose :sub_service_requests, using: V1::SubServiceRequestShallow
  end

  class StudyFullWithShallowReflection < ProtocolFullWithShallowReflection
    root 'protocols', 'protocol'
  end

  class SubServiceRequestFullWithShallowReflection < SubServiceRequestFull
    root 'sub_service_requests', 'sub_service_request'

    expose :service_request,  using: V1::ServiceRequestShallow
    expose :line_items,       using: V1::LineItemShallow
  end

  class VisitFullWithShallowReflection < VisitFull
    root 'visits', 'visit'

    expose :line_items_visit,  using: V1::LineItemsVisitShallow
    expose :visit_group,       using: V1::VisitGroupShallow
  end

  class VisitGroupFullWithShallowReflection < VisitGroupFull
    root 'visit_groups', 'visit_group'

    expose :arm,    using: V1::ArmShallow
    expose :visits, using: V1::VisitShallow
  end
end
