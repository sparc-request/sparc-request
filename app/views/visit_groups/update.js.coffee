# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
<% if @errors %>
$("#modal_place #modal_errors").html("<%= escape_javascript(render( 'shared/modal_errors', errors: @errors )) %>")
<% else %>
$('.visit-group-<%=@visit_group.id%>:visible').replaceWith("<%= j render 'service_calendars/master_calendar/pppv/visit_group', visit_group: @visit_group, tab: params[:tab], page: @page, pages: @pages, portal: @portal, review: @review, admin: @admin, merged: @merged, consolidated: @consolidated, statuses_hidden: params[:statuses_hidden] %>")
$('.visit-group-select:visible').html("<%= j render 'service_calendars/master_calendar/pppv/visit_group_page_select', service_request: @service_request, sub_service_request: @sub_service_request, arm: @visit_group.arm, tab: params[:tab], page: @page, pages: @pages, portal: @portal, review: @review, admin: @admin, merged: @merged, consolidated: @consolidated, statuses_hidden: params[:statuses_hidden] %>")
$('#visits-select-for-<%=@visit_group.arm_id%>.selectpicker').selectpicker()
$('#modal_place').modal('hide')
<% end %>
