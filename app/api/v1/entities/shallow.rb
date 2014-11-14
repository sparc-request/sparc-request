module V1

  class Shallow < Grape::Entity
    expose  :id, as: :sparc_id
    expose  :remote_service_callback_url, as: :callback_url
  end

  class ArmShallow < Shallow
    root 'arms', 'arm'
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
