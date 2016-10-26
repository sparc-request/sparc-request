# Copyright © 2011-2016 MUSC Foundation for Research Development
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
<% if @errors.present? %>
$("#modal_errors").html("<%= escape_javascript(render('shared/modal_errors', errors: @errors)) %>")
<% else %>
$("#modal_place").modal('hide')
# Send the user back to dashboard if theyre a member and not an admin
<% if @return_to_dashboard %>
window.location = "/dashboard"
# Update the entire view to account for the current users rights change
<% elsif @current_user_updated %>
$("#summary-panel").html("<%= escape_javascript(render('dashboard/protocols/summary', protocol: @protocol, protocol_type: @protocol_type, permission_to_edit: @permission_to_edit || @admin)) %>")
$("#authorized-users-panel").html("<%= escape_javascript(render('dashboard/associated_users/table', protocol: @protocol, permission_to_edit: @permission_to_edit || @admin)) %>")
$("#documents-panel").html("<%= escape_javascript(render( 'dashboard/documents/documents_table', protocol: @protocol, permission_to_edit: @permission_to_edit || @admin )) %>")
$("#service-requests-panel").html("<%= escape_javascript(render('dashboard/service_requests/service_requests', protocol: @protocol, permission_to_edit: @permission_to_edit, user: @user, view_only: false)) %>")

$("#associated-users-table").bootstrapTable()
$("#documents-table").bootstrapTable()
$(".service-requests-table").bootstrapTable()

$('.service-requests-table').on 'all.bs.table', ->
  $(this).find('.selectpicker').selectpicker() #Find descendant selectpickers
<% else %>
$("#associated-users-table").bootstrapTable 'refresh', {silent: true}
<% end %>
$("#flashes_container").html("<%= escape_javascript(render('shared/flash')) %>")
<% end %>
