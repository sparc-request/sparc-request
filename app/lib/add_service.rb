class AddService

  def initialize(service_request, service_id, current_user)
    @service_request = service_request
    @service_id = service_id
    @current_user = current_user
  end

  def existing_service_ids
    @service_request.line_items.reject{ |line_item| FINISHED_STATUSES.include?(line_item.status) }.map(&:service_id)
  end

  def generate_new_service_request
    service        = Service.find(@service_id)
    new_line_items = @service_request.create_line_items_for_service(
      service: service,
      optional: true,
      existing_service_ids: existing_service_ids,
      recursive_call: false ) || []
    create_sub_service_requests(new_line_items)
  end

  private

  def create_sub_service_requests(new_line_items)
    @service_request.reload
    @service_request.previous_submitted_at = @service_request.submitted_at
    new_line_items.each do |li|
      ssr = find_or_create_sub_service_request(li, @service_request)
      li.update_attribute(:sub_service_request_id, ssr.id)
      if @service_request.status == 'first_draft'
        ssr.update_attribute(:status, 'first_draft')
      elsif ssr.status.nil? || (ssr.can_be_edited? && ssr_has_changed?(@service_request, ssr))
        ssr.update_attribute(:status, 'draft')
      end
    end
    @service_request.ensure_ssr_ids
  end

  def find_or_create_sub_service_request(line_item, service_request)
    organization = line_item.service.process_ssrs_organization
    service_request.sub_service_requests.each do |ssr|
      if (ssr.organization == organization) && !ssr.is_complete?
        return ssr
      end
    end
    sub_service_request = service_request.sub_service_requests.create(
      organization_id: organization.id
    )
    service_request.ensure_ssr_ids

    sub_service_request
  end

  def ssr_has_changed?(service_request, sub_service_request) #specific ssr has changed?
    previously_submitted_at = service_request.previous_submitted_at.nil? ? Time.now.utc : service_request.previous_submitted_at.utc
    unless sub_service_request.audit_report(@current_user, previously_submitted_at, Time.now.utc)[:line_items].empty?
      return true
    end
    return false
  end
end

