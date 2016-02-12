class SetupProtocol

  def initialize(portal, protocol, user, service_request_id, cookie)
    @portal = portal
    @protocol = protocol
    @user = user
    @service_request_id = service_request_id
    @cookie = cookie
  end

  def from_portal?
    return @portal == "true"
  end

  def set_portal
    @portal
  end

  def setup
    find_service_request
    populate_for_edit
    requester_id
    set_cookies
  end

  def find_service_request
    unless from_portal?
      @service_request = ServiceRequest.find @service_request_id
      @epic_services = @service_request.should_push_to_epic? if USE_EPIC
    end
  end

  def populate_for_edit
    @protocol.populate_for_edit
  end

  def requester_id
    @protocol.requester_id = @user.id
  end

  def set_cookies
    current_step_cookie = @cookie
    @cookie = 'protocol'
  end
end
