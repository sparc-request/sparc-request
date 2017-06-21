(exports ? this).reload_calendar = (arm_id, sr_id, scroll) ->
  tab = $('li.custom-tab.active a').last().attr('id')
  tab = tab.substring(0, tab.indexOf("tab") - 1).replace("-", "_")
  data = $('#service-calendars').data()
  data.scroll = scroll
  data.tab = tab
  data.arm_id = arm_id
  data.service_request_id = sr_id
  data.sub_service_request_id = data.subServiceRequestId
  data.protocol_id = data.protocolId
  $.get '/service_calendars/table.js', data

(exports ? this).$.fn.renderFormErrors = (modelName, errors) ->
  form = this

  this.clearFormErrors()

  $.each(errors, (field, messages) ->
    input = form.find('input, select, textarea').filter(->
      name = $(this).attr('name')
      if name
        name.match(new RegExp(modelName + '\\[' + field + '\\(?'))
    )
    input.closest('.form-group').addClass('has-error')
    input.parent().append('<span class="help-block">' + $.map(messages, (m) -> m.charAt(0).toUpperCase() + m.slice(1)).join('<br />') + '</span>')
  )

$.fn.clearFormErrors = () ->
  this.find('.form-group').removeClass('has-error')
  this.find('span.help-block').remove()

$ ->

  $(document).on 'ajax:success', '.visit-group-form', ->
    scroll = $(this).parents('footer').siblings('#container').find('.scrolling-div').length > 0
    arm_id = $('.visit-group-form .vg-arm-id').val()
    sr_id = $('.visit-group-form .vg-sr-id').val()
    reload_calendar(arm_id, sr_id, scroll)
    $('#modal_place').modal('hide')

  $(document).on 'ajax:error', '.visit-group-form', (e, data, status, xhr) ->
    $('.visit-group-form').renderFormErrors('visit_group', jQuery.parseJSON(data.responseText))

  $(document).on 'click', '.edit-visit-group', ->
    id = $(this).data('id')
    srId = $(this).data('service-request-id')
    armId = $(this).data('arm-id')
    $.ajax
      type: 'GET'
      url: "/visit_groups/#{id}/edit?service_request_id=#{srId}&&arm_id=#{armId}"


