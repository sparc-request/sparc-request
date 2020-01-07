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
<% @errors.zip(@errors.full_messages).each do |error, message| %>
if !$("#<%=@klass%>-<%=@object.id%>-<%=error[0]%>").parents('.form-group').hasClass('is-invalid')
  $("#<%=@klass%>-<%=@object.id%>-<%=error[0]%>").parents('.form-group').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
  <% if @field == 'active' %>
  if $('#modalContainer:visible').length > 0
    $("#<%=@klass%>-<%=@object.id%>-<%=@field%>").attr("checked", false)
  else
    AlertSwal.fire(
      type: 'error'
      title: I18n.t('activerecord.errors.models.form.attributes.active.taken')
    )
  <% end %>
<% end %>
<% else %>
$("#<%=@klass%>-<%=@object.id%>-<%=@field%>").parents('.form-group').removeClass('is-invalid')
$("#<%=@klass%>-<%=@object.id%>-<%=@field%>").siblings('.help-block').remove()

<% if @field == 'access_code' %>
$('[id^=survey][id$=version]').val("<%= @object.version %>")
$('[id^=survey][id$=version]').parents('.form-group').removeClass('is-invalid')
$('[id^=survey][id$=version]').siblings('.help-block').remove()
<% end %>

<% if @field == 'active' %>
if $('#modalContainer:visible').length == 0
  $(".<%=@object.class.name.snakecase.dasherize.downcase%>-table").bootstrapTable('refresh')
<% end %>

<% if @object.is_a?(Question) %>
$(".question-options[data-question-id='<%=@object.id%>']").html('<%= j render "surveyor/surveys/form/form_partials/#{@object.question_type}_example", question: @object %>')
$('.selectpicker').selectpicker()
<% end %>
<% end %>
