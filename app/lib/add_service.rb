# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class AddService
  def initialize(service_request, service_id, requester, new_request=false, confirmed=false)
    @service_request  = service_request
    @service          = Service.find(service_id)
    @requester        = requester
    @new_request      = new_request
    @confirmed        = confirmed
  end

  def generate_new_service_request
    @service_request.save
    new_line_items = @service_request.create_line_items_for_service(service: @service, optional: true, recursive_call: false ) || []
    create_sub_service_requests(new_line_items)
  end

  def confirm_new_request?
    !@confirmed && @new_request && @service_request.line_items.none?
  end

  def duplicate_service?
    @service_request.line_items.incomplete.where(service: @service).any?
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
      organization: organization, service_requester: @requester
    )
    service_request.ensure_ssr_ids

    sub_service_request
  end

  def ssr_has_changed?(service_request, sub_service_request) #specific ssr has changed?
    previously_submitted_at = service_request.previous_submitted_at.nil? ? Time.now.utc : service_request.previous_submitted_at.utc

    sub_service_request.audit_report(@requester, previously_submitted_at, Time.now.utc)[:line_items].any?
  end
end

