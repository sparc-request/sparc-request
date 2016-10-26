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

# TODO - this could be cleaned up
if $(".project_role_<%= @project_role.identity.id %>").length > 0 and "<%= @can_edit %>" == "false"
  alert("<%= @project_role.identity.display_name %> has already been added to this project. Click edit in the table below to make changes to this user.")
else if "<%= @errors.any? %>" == "true"
  $('.field_with_errors label').unwrap()
  $('#user_detail_errors').html("<h2><%= pluralize(@errors.size, 'error') %> prohibited this user from being added</h2><p>There were problems with the following <%= pluralize(@errors.size, 'fields') %>:</p><ul>")
  <% @errors.each do |field, message| %>
  $('#user_detail_errors ul').append("<li><%= message %></li>")
  $(".<%= field %> label").wrap("<div class='field_with_errors' />")
  <% end %>
  $('#user_detail_errors').append("</ul>")

  $('#user_detail_errors').show()
  $('.user_info').show()
else if $(".project_role_<%= @project_role.identity.id %>").length > 0 and "<%= @can_edit %>" == "true"
  $('#user_detail_errors').hide()
  $(".project_role_<%= @project_role.identity.id %>").replaceWith("<%= escape_javascript(render :partial => 'shared/user_proxy_right', :locals => {:project_role => @project_role, :protocol_use_epic => @protocol_use_epic}) %>")
  $('.user_added_message p').html("<%= escape_javascript(t("protocol_shared.update_user")) %>")
  $('.user_added_message').show().fadeOut(2500, 'linear')
  $('.field_with_errors').removeClass('field_with_errors')
  $('.add-user-details').hide()
else
  $('#user_detail_errors').hide()
  $('.user-details-left').hide()
  $('.user-details-right').hide()
  $('.authorized-users tbody').append("<%= escape_javascript(render :partial => 'shared/user_proxy_right', :locals => {:project_role => @project_role, :protocol_use_epic => @protocol_use_epic}) %>")
  $('.user_added_message p').html("<%= escape_javascript(t("protocol_shared.add_user")) %>")
  $('.user_added_message').show().fadeOut(2500, 'linear')
  $('.field_with_errors').removeClass('field_with_errors')
  $('.add-user-details').hide()
