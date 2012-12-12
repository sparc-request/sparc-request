class Subsidy::ObisEntitySerializer
  def as_json(subsidy, options = nil)
    h = {
      'pi_contribution' => subsidy.pi_contribution,
    }

    return [ subsidy.sub_service_request.organization.try(:obisid), h ]
  end

  def update_from_json(subsidy, h, options = nil)
    subsidy.update_attributes!(
      pi_contribution: h[1]['pi_contribution'])
  end
end

class Subsidy
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

