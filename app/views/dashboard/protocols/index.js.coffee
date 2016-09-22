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
$("#filterrific_form").html("<%= escape_javascript(render( '/dashboard/protocol_filters/filter_protocols_form', filterrific: @filterrific, current_user: @user, admin: @admin )) %>")
$("#filterrific_results").html("<%= escape_javascript(render( '/dashboard/protocols/protocols_list', protocols: @protocols, current_user: @user, admin_protocols: @admin_protocols, filterrific_params: @filterrific_params, page: @page )) %>")
$(".selectpicker").selectpicker()

<% if @sorted_by %>
$(".protocol-sort[name='<%= @sort_name %>'] .<%= @sort_order %>").addClass('sort-active')
$(".protocol-sort[name='<%= @sort_name %>'] .<%= @new_sort_order %>").removeClass('sort-active')
$(".protocol-sort[name='<%= @sort_name %>']").data('sort-order', "<%= @new_sort_order %>")
<% end %>
