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

  class ProjectRoleFullWithShallowReflection < ProjectRoleFull
    root 'project_roles', 'project_role'

    expose :protocol, using: V1::ProtocolShallow
    expose :identity, using: V1::IdentityShallow
  end

  class ProtocolFullWithShallowReflection < ProtocolFull
    root 'protocols', 'protocol'

    expose :arms,             using: V1::ArmShallow
    expose :service_requests, using: V1::ServiceRequestShallow
    expose :project_roles,    using: V1::ProjectRoleShallow
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
