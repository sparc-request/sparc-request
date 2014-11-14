module CwfHelper

  def cwf_sends_api_get_request_for_resource(klass, object_id, depth)
    http_login

    if depth
      params = { depth: depth }
    else
      params = {}
    end

    get "/v1/#{klass}/#{object_id}.json", params, @env
  end

  def cwf_sends_api_get_request_for_resources(klass, depth, ids=[])
    http_login

    params = Hash.new

    if ids.any?
      params.merge!({ ids: ids })
    end

    if depth.present?
      params.merge!({ depth: depth })
    end

    get "/v1/#{klass}.json", params, @env
  end
end
