$.fn.clear_form_errors = () ->
  this.find('.form-group').removeClass('has-error')
  this.find('span.help-block').remove()

$.fn.render_form_errors = (model_name, errors) ->
  form = this
  this.clear_form_errors()

  $.each(errors, (field, messages) ->
    input = form.find('input, select, textarea').filter(->
      name = $(this).attr('name')
      if name
        name.match(new RegExp(model_name + '\\[' + field + '\\(?'))
    )
    input.closest('.form-group').addClass('has-error')
    input.parent().append('<span class="help-block">' + $.map(messages, (m) -> m.charAt(0).toUpperCase() + m.slice(1)).join('<br />') + '</span>')
  )

$ ->

  $('#modal_place').on 'shown.bs.modal', ->
    $('.new_feedback').ajaxError (e, data) ->
      $('.new_feedback').render_form_errors('feedback', JSON.parse(data.responseText))
