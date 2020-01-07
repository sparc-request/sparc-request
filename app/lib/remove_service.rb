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

class RemoveService
  def initialize(service_request, line_item_id, current_user, page, confirmed)
    @service_request  = service_request
    @line_item        = service_request.line_items.find(line_item_id)
    @ssr              = @line_item.sub_service_request
    @current_user     = current_user
    @page             = page
    @confirmed        = confirmed
  end

  def confirm_previously_submitted?
    # If the SSR is in draft status, treat it as if it hasn't been submitted before.
    !@confirmed && @ssr.previously_submitted? && !@ssr.is_in_draft?
  end

  def confirm_last_service?
    !@confirmed && @page != 'catalog' && @service_request.line_items.count == 1
  end

  def line_item
    @line_item
  end

  def sub_service_request
    @ssr
  end

  def remove_service
    if @line_item.sub_service_request.can_be_edited?
      @service_request.line_items.where(service: @line_item.service.related_services).update_all(optional: true)
      @line_item.destroy

      if @ssr.line_items.empty?
        NotifierLogic.new(@service_request, @current_user).ssr_deletion_emails(deleted_ssr: @ssr, ssr_destroyed: true, request_amendment: false, admin_delete_ssr: false)
        @ssr.destroy
      else
        @ssr.update_attribute(:status, 'draft') unless @ssr.status == 'first_draft'
      end

      @service_request.reload
    end
  end
end
