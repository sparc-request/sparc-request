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
