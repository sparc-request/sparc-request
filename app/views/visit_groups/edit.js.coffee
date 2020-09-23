# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

$vg       = $(".visit-group-<%= @visit_group.id %>")
title     = "#{I18n.t("visit_groups.edit")} <a href='#' class='close' data-dismiss='alert'>&times;</a>"
$content  = $("<%= j render 'form', visit_group: @visit_group, visit_group_clone: @visit_group_clone, arm: @arm, service_request: @service_request, sub_service_request: @sub_service_request, tab: @tab, page: @page, pages: @pages %>")

# If a different visit popover is already open, close it first
if $('.visit-group-popover') && !$("form#edit_visit_group_<%= @visit_group.id %>").length
  $('.visit-group-popover').popover('hide')
  $('.visit-group.active').removeClass('active')

# If the visit is already open
# else open the visit as a popover
if $(".visit-group-<%= @visit_group.id %>-popover").length
  # Close the popover if clicking the same visit to close it
  # Use params[:visit_group] to make sure the popover stays open
  # when changing the position attribute
  # else
  # Re-render the popover with updated content\
  if <%= params[:visit_group].present? %>
    $($('.visit-group-popover').data('bs.popover').tip).find('.popover-body').html($content)
  else
    $vg.removeClass('active').popover('dispose')
else
  $vg.popover(
    title:      title
    content:    $content
    template:   '<div class="popover visit-group-popover visit-group-<%= @visit_group.id %>-popover" role="tooltip"><div class="arrow"></div><h3 class="popover-header"></h3><div class="popover-body"></div></div>'
    html:       true
    trigger:    'manual'
    placement:  'top'
  )

  # Logic for smoother closing of visit group popovers
  $vg.on 'shown.bs.popover', ->
    $(document).one 'hide.bs.popover', 'body', ->
      $vg.removeClass('active').trigger('focus')
  $vg.addClass('active').trigger('focus').popover('show')

  # Force the menu to dropdown to the right
  # bootstrap-select doees not seem to have a method to add classes
  # to the menu
  $('[id=visit_group_position]').siblings('.dropdown-menu').addClass('dropdown-menu-right')

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
