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
$("[name^='protocol']:not([type='hidden']):not(.research-involving, .study-type, .impact-area, .affiliation)").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('#studyTypeQuestionsContainer').removeClass('is-valid')
$('.form-error').remove()

# RMID Errors
<% @errors.messages[:base].each do |message| %>
$('#protocol_research_master_id').parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>

<% @errors.messages.select{ |attr| attr != :study_type_answers }.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='protocol[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>

<% @protocol.primary_pi_role.errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='protocol[primary_pi_role_attributes][<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>

<% @protocol.human_subjects_info.errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='protocol[human_subjects_info_attributes][<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>

<% if @errors.messages[:study_type_answers][0] %>
<% @errors.messages[:study_type_answers][0].each do |question_id, message| %>
$("#study_type_answer_<%= question_id %>").children('.form-group:last-of-type').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>

if $('.is-invalid').length
  $('html, body').animate({ scrollTop: $('.is-invalid').first().offset().top }, 'slow')
<% elsif @locked %>
$('#calendarStructureCard').replaceWith("<%= j render '/dashboard/calendar_structure/table', protocol: @protocol %>")
$('#calendarStructureTable').bootstrapTable()

$(document).trigger('ajax:complete') # rails-ujs element replacement bug fix
<% elsif request_referrer_action == 'show' %>
# Do nothing - updating Milestones
<% else %>
window.location = "<%= dashboard_protocol_path(@protocol) %>"
<% end %>
