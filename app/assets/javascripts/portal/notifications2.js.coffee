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

$(document).ready ->

  $(document).on('click', '.new_notification', ->
    # Admin portal user roles notification button click
    sub_service_request_id = $(this).data('sub-service-request-id')
    identity_id = $(this).data('identity-id')
    is_service_provider = $(this).data('is-service-provider')
    current_user_id = $(this).data('current-user-id')

    if current_user_id == identity_id
      alert("You can not send a message to yourself.")
    else
      data =
        "sub_service_request_id"  : sub_service_request_id
        "identity_id"             : identity_id
        "is_service_provider"     : is_service_provider
      $.ajax
        type: 'GET'
        url:  "/portal/notifications/new"
        data: data
  )

  $(document).on('click', '.notifications_row > .from,.subject,.preview,.time', ->
    #if you click on the row, it opens the notification show
    row_index   = $(this).parents("tr").data("index")
    notification_id = $(this).parents("table.notifications_table").bootstrapTable("getData")[row_index].id
    data =
      'notification_id': notification_id
    $.ajax
      type: 'GET'
      url: "/portal/messages"
      data: data
  )

  $(document).on('click', '.notifications_row > .bs-checkbox', ->
    #clicks checkbox if you click in the same td
    $(this).children("input[type='checkbox']").trigger('click')
  )

  $('.hidden-message').live('click', ->
    message_id = $(this).data('message_id')
    message_header = $(this).children('.message-header')
    $(this).removeClass('hidden-message').addClass('shown-message')
    message_header.children('.message_recipients').removeClass('hidden').addClass('shown')
    $(this).children('.truncated-message-body').addClass('shown-message-body').removeClass('truncated-message-body')
    $(this).children('.message-header').addClass('clickable-message-header')
    $(".gray_arrow_down_#{message_id}").hide()
    $(".white_arrow_up_#{message_id}").show()
  )

  $('.clickable-message-header').live('click', ->
    message = $(this).parent('.shown-message')
    message_id = message.data('message_id')
    message.children('message-header').removeClass('clickable-message-header')
    message.removeClass('shown-message').addClass('hidden-message')
    $(this).children('.message_recipients').removeClass('shown').addClass('hidden')
    message.children('.shown-message-body').addClass('truncated-message-body').removeClass('shown-message-body')
    $(".gray_arrow_down_#{message_id}").show()
    $(".white_arrow_up_#{message_id}").hide()
  )

  $(document).on 'change', '.new-notification', ->
    # user portal
    $selected_options = $('option:selected', this)

    if $selected_options.length > 0
      $selected_option       = $selected_options.first()
      sub_service_request_id = $selected_option.data('sub-service-request-id')
      identity_id            = $selected_option.data('identity-id')
      is_service_provider    = $selected_option.data('is-service-provider')
      current_user_id        = $selected_option.data('current-user-id')
      possible_recipients    = $.map $('option', this), (opt) ->
        $(opt).data('identity-id')
      $this                  = $(this)
      reset_select_picker    = ->
        $this.selectpicker('deselectAll')
        $this.selectpicker('render')

      if current_user_id == identity_id
        alert("You can not send a message to yourself.")
        reset_select_picker()
      else
        $.ajax
          type: 'GET'
          url:  '/portal/notifications/new.js'
          data:
            sub_service_request_id: sub_service_request_id
            identity_id:            identity_id
            is_service_provider:    is_service_provider
            possible_recipients:    possible_recipients
          success: ->
            reset_select_picker()

  $(document).on 'click', 'button.message.new',  ->
    data = notification_id: $(this).data('notification-id')
    $.ajax
      type: 'GET'
      url: '/portal/messages/new'
      data: data

  $(document).on 'click', 'button.mark_as_read_unread',  ->
    selections = $("#notifications-table").bootstrapTable 'getSelections'
    notification_ids = selections.map( (hash, i) -> return hash['id'] )
    if notification_ids.length > 0
      read_or_unread = $(this).data('read')
      data =
        'notification_ids'  : notification_ids
        'read'              : read_or_unread
      $.ajax
        type: 'PUT'
        url: '/portal/notifications/mark_as_read'
        data: data

  $(document).on 'click', 'button#notifications_sent',  ->
    $(".notification_nav").removeClass('btn-primary').addClass('btn-default').find(".glyphicon-refresh").hide()
    $(this).removeClass('btn-default').addClass('btn-primary').find(".glyphicon-refresh").show()
    $("#notification_tabs").data("selected", "sent")
    $("#notifications-table").bootstrapTable 'refresh', {query: {table: "sent"}}

  $(document).on 'click', 'button#notifications_inbox',  ->
    $(".notification_nav").removeClass('btn-primary').addClass('btn-default').find(".glyphicon-refresh").hide()
    $(this).removeClass('btn-default').addClass('btn-primary').find(".glyphicon-refresh").show()
    $("#notification_tabs").data("selected", "inbox")
    $("#notifications-table").bootstrapTable 'refresh', {query: {table: "inbox"}}

  $(document).on 'click', 'button#compose_notification',  ->
    data =
      "sub_service_request_id"  : $(this).data('sub-service-request-id')
    $.ajax
      type: 'GET'
      url:  "/portal/notifications/new"
      data: data

  window.notifications_row_style = (row, index) ->
    class_string = 'notifications_row'
    if not row.read
      #makes unread messages appear green in notifications bs table
      class_string += ' success'
    return { classes: class_string }

  window.refresh_notifications_table = ->
    table = $("#notification_tabs").data("selected")
    $("#notifications-table").bootstrapTable 'refresh', {query: {table: "#{table}"}}
