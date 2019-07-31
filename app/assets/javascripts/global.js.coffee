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

# Provide the CSRF Authenticity Token for all Ajax requests
$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

$(document).ready ->
  initializeSelectpickers()
  initializeDateTimePickers()
  initializeTooltips()
  initializePopovers()
  initializeToggles()
  initializeTables()
  setRequiredFields()
  $('html').addClass('ready')

  $(document).on 'ajaxSuccess ajax:complete', ->
    initializeSelectpickers()
    initializeDateTimePickers()
    initializeTooltips()
    initializePopovers()
    initializeToggles()
    initializeTables()
    setRequiredFields()

  # Back To Top button scroll
  $(document).on 'click', '#backToTop', ->
    $('html, body').animate({ scrollTop: 0 }, 'slow')

  # Smooth scroll anchors with hash
  $(document).on 'click', "a[href^='#']", (event) ->
    if !$(this).data('toggle')
      event.preventDefault()
      $('html, body').animate({ scrollTop: $(this.hash).offset().top }, 'slow')

  $(document).on 'keydown change change.datetimepicker', '.is-valid, .is-invalid', ->
    $(this).removeClass('is-valid is-invalid').find('.form-error').remove()

  $(window).scroll ->
    if $(this).scrollTop() > 50
      $('#backToTop').removeClass('hide')
    else
      $('#backToTop').addClass('hide')

  $(document).on 'show.bs.collapse hide.bs.collapse', '.collapse, .collapsing', ->
    $control = $("[href='##{$(this).attr('id')}']")

    if $control.length == 0
      $control = $("[data-target='##{$(this).attr('id')}']")

    if $control.attr('alt')
      text  = $control.text()
      alt   = $control.attr('alt')

      $control.text(alt)
      $control.attr('alt', text)

  $(document).on 'show.bs.collapse hide.bs.collapse', 'div[data-toggle=collapse] + .collapse', (event) ->
    if event.delegateTarget.activeElement.tagName == 'A'
      event.preventDefault()

  $(document).on('mouseover', 'div[data-toggle=collapse]', (event) ->
    if event.target.tagName == 'DIV'
      $(this).addClass('hover')
    else
      $(this).removeClass('hover')
  ).on('mouseleave', 'div[data-toggle=collapse]', (event) ->
    $(this).removeClass('hover')
  ).on('mousedown', 'div[data-toggle=collapse]', (event) ->
    if event.target.tagName == 'DIV'
      $(this).addClass('active')
  ).on('mouseup', 'div[data-toggle=collapse]', (event) ->
    if event.target.tagName == 'DIV'
      $(this).removeClass('active')
  )

  $(document).on 'click', '.copy-to-clipboard', ->
    $that = $(this)

    document.getElementById($(this).data('target')).select()
    document.execCommand('copy')

    $(this).parents('.input-group').siblings('.help-text').remove()
    $(this).parents('.input-group').after("<span class='help-text text-success'>#{I18n.t('actions.copy_clipboard.complete')}</span>")

    setTimeout (->
      $that.parents('.input-group').siblings('.help-text').fadeOut('slow', ->
        $that.parents('.input-group').siblings('.help-text').remove()
      )
    ), 1500

  $(document).on('keydown', 'input[type=tel]', (event) ->
    val       = $(this).val()
    key       = event.keyCode || event.charCode

    if [8, 46].includes(key) # Backspace or Delete keys
      if val.length == 2
        $(this).val('')
      else if val.length == 7
        $(this).val(val.substr(0, 5))
      else if val.length == 11
        $(this).val(val.substr(0,10))
      else if val.length == 20
        $(this).val(val.substr(0, 15))
    else if key == 9 # Allow tabbing
      return true
    else if (key >= 96 && key <= 105) || (key >= 48 && key <= 57) && !event.shiftKey # Numerical keypresses
      if val.length == 0
        $(this).val('(')
      else if val.length == 4
        $(this).val(val + ') ')
      else if val.length == 9
        $(this).val(val + '-')
      else if val.length == 14
        $(this).val(val + " #{I18n.t('constants.phone.extension')} ")
    else
      event.stopImmediatePropagation()
      return false
  ).on('keyup', 'input[type=tel]', (event) ->
    key = event.keyCode || event.charCode
    end = this.selectionEnd
    
    if key == 9 # Remove range selection when focusing the input
      this.setSelectionRange(end, end)
  )

(exports ? this).initializeSelectpickers = () ->
  $('.selectpicker').each ->
    $(this).selectpicker() if $(this).siblings('.dropdown-toggle').length == 0

(exports ? this).initializeDateTimePickers = () ->
  $('.datetimepicker.date:not(.time)').datetimepicker({ format: 'L' })
  $('.datetimepicker.time:not(.date)').datetimepicker({ format: 'T' })
  $('.datetimepicker.date.time').datetimepicker({ format: 'LT' })

(exports ? this).initializeTooltips = () ->
  $('.tooltip').tooltip('hide')
  $('[data-toggle=tooltip]').tooltip({ delay: { show: 500 }, animation: false })

(exports ? this).initializePopovers = () ->
  $('[data-toggle=popover]').popover()

(exports ? this).initializeToggles = () ->
  $('input[data-toggle=toggle]').bootstrapToggle()

(exports ? this).initializeTables = () ->
  $('[data-toggle=table]').bootstrapTable()

(exports ? this).setRequiredFields = () ->
  $('.required:not(.has-indicator)').addClass('has-indicator').append('<span class="required-indicator text-danger ml-1">*</span>')
  $('.has-indicator:not(.required)').removeClass('has-indicator').children('.required-indicator').remove()

(exports ? this).getSRId = ->
  $("input[name='srid']").val()

(exports ? this).getSSRId = ->
  $("input[name='sub_service_request_id']").val()

VALID_MONETARY_KEYS = [
  8, # backspace
  37, 38, 39, 40, # arrow keys
  46, # Delete
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, # 0-9
  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, # numpad 0-9
  110, # decimal
  190 # period
]

(exports ? this).validateMonetaryInput = (e) ->
  charCode = if e.which then e.which else event.keyCode
  element  = e.target

  # dont allow multiple decimal points
  if (charCode == 110 || charCode == 190) && $(element).val().indexOf('.') >= 0
    e.preventDefault()

  # make sure only valid keys are allowed
  if !VALID_MONETARY_KEYS.includes(charCode)
    e.preventDefault()

(exports ? this).formatMoney = (n, t=',', d='.', c='$') ->
  s = if n < 0 then "-#{c}" else c
  i = Math.abs(n).toFixed(2)
  j = (if (i.length > 3 && i > 0) then i.length % 3 else 0)
  s += i.substr(0, j) + t if j
  return s + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t)

(exports ? this).humanize_string = (string) ->
  new_str = ''
  arr     = string.split('_')
  for word in arr
    new_str += word.charAt(0).toUpperCase() + word.slice(1) + ' '
  return new_str

(exports ? this).refresh_study_schedule = () ->
  $('#service-calendar .tab-content .tab-pane.active').load $('#service-calendar .active a').attr("data-url"), (result) ->
    $('#service-calendar .active a').tab('show')
