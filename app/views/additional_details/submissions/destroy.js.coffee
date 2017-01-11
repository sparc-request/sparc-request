# Copyright © 2011 MUSC Foundation for Research Development
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

<% if @submission.destroy %>
<% if params[:protocol_id] && params[:sr_id] %>
$('.additional-details-submissions-panel').html("<%= j render 'submissions_panel', protocol: @protocol %>")
<% end %>
<% if params[:protocol_id] && params[:line_item_id] %>
$('.additional-details-submissions-panel').html("<%= j render 'submissions_panel', protocol: @protocol, submissions: @submissions %>")
$('.document-management-submissions').html("<%= j render 'additional_details/document_management_submissions', service_request: @service_request %>")
$("#service-requests-panel").html("<%= j render 'dashboard/service_requests/service_requests', protocol: @protocol, permission_to_edit: @permission_to_edit, user: @user, view_only: false, show_view_ssr_back: false %>")
$('.service-requests-table').bootstrapTable()

$('.service-requests-table').on 'all.bs.table', ->
  $(this).find('.selectpicker').selectpicker()
<% else %>
$('.submissions-index-table').html("<%= j render 'additional_details/submissions/submission_index_table', submissions: @submissions %>")
<% end %>
<% else %>
swal("Error", "Submission could not be deleted", "error")
<% end %>
