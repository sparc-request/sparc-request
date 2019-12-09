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

$ ->
  $('html').addClass('ready')
  initializeSelectpickers()
  initializeDateTimePickers()
  initializeTooltips()
  initializePopovers()
  initializeToggles()
  initializeTables()
  setRequiredFields()

  stickybits('.position-sticky, .sticky-top')

  $(document).on 'load-success.bs.table search.bs.table sort.bs.table column-switch.bs.table ajax:complete', (e) ->
    initializeSelectpickers()
    initializeDateTimePickers()
    initializeTooltips()
    initializePopovers()
    initializeToggles()
    initializeTables()
    setRequiredFields()

  # Back To Top button scroll
  $(window).scroll ->
    if $(this).scrollTop() > 50
      $('#backToTop').removeClass('hide')
    else
      $('#backToTop').addClass('hide')

  $(document).on 'click', '#backToTop', ->
    $('html, body').animate({ scrollTop: 0 }, 'slow')

  # Smooth scroll anchors with hash
  $(document).on 'click', "a[href^='#']:not(data-toggle)", (event) ->
    if !$(this).data('toggle')
      event.preventDefault()
      $('html, body').animate({ scrollTop: $(this.hash).offset().top }, 'slow')

  # Form validation
  $(document).on 'keydown change change.datetimepicker', '.is-valid:not(.persist-validation), .is-invalid:not(.persist-validation)', ->
    $(this).removeClass('is-valid is-invalid').find('.form-error').remove()

  # Smooth Collapses
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
    if ['A', 'BUTTON'].includes(event.target.tagName) || (['I', 'SPAN'].includes(event.target.tagName) && ['A', 'BUTTON', 'SPAN'].includes(event.target.parentElement.tagName))
      $(this).removeClass('hover')
    else
      $(this).addClass('hover')
  ).on('mouseleave', 'div[data-toggle=collapse]', (event) ->
    $(this).removeClass('hover')
  ).on('mousedown', 'div[data-toggle=collapse]', (event) ->
    if event.target.tagName == 'DIV'
      $(this).addClass('active')
  ).on('mouseup', 'div[data-toggle=collapse]', (event) ->
    if event.target.tagName == 'DIV'
      $(this).removeClass('active')
  )

  # Close dropdowns after clicking an item
  $(document).on 'ajax:beforeSend', '.dropdown:not(.nav-item) .dropdown-item', ->
    $(this).parents('.dropdown-menu').siblings('.dropdown-toggle').dropdown('hide')
    return true

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

  # Phone Field Handler
  $(document).on('keydown', 'input[type=tel]', (event) ->
    val = $(this).val()
    key = event.keyCode || event.charCode
    end = this.selectionEnd

    if [8, 46].includes(key) # Backspace or Delete keys
      if end == this.selectionStart
        if val.charAt(end - 2) == '(' && val.length == 2
          $(this).val('')
        else if val.charAt(end - 3) == ')' && val.length == 7
          $(this).val(val.substr(0, 5))
        else if val.charAt(end - 2) == '-' && val.length == 11
          $(this).val(val.substr(0,10))
        else if val.substr(end - 6).slice(0, -1) == " #{I18n.t('constants.phone.extension')} "
          $(this).val(val.substr(0, 15))
        else if !val.charAt(end-1).trim().length || isNaN(val.charAt(end - 1))
          event.stopImmediatePropagation()
          return false
    else if key == 9 # Allow tabbing
      return true
    else if key == 37 # Allow limited Left Arrow usage
      if val.substr(end - 4, I18n.t('constants.phone.extension').length) == I18n.t('constants.phone.extension')
        this.setSelectionRange(end - 4, end - 4)
      else if val.charAt(end - 1) == '-'
        this.setSelectionRange(end, end)
      else if val.charAt(end - 2) == ')'
        this.setSelectionRange(end - 1, end - 1)
      else if val.charAt(end - 1) == '('
        event.stopImmediatePropagation()
        return false
    else if key == 39 # Allow limited Right Arrow usage
      if val.substr(end + 1, I18n.t('constants.phone.extension').length) == I18n.t('constants.phone.extension')
        this.setSelectionRange(end + 4, end + 4)
      else if val.charAt(end) == '-'
        this.setSelectionRange(end, end)
      else if val.charAt(end) == ')'
        this.setSelectionRange(end + 1, end + 1)
    else if (key >= 96 && key <= 105) || (key >= 48 && key <= 57) && !event.shiftKey
      # Permit numerical keypresses
    else
      event.stopImmediatePropagation()
      return false
  ).on('keyup', 'input[type=tel]', (event) ->
    val = $(this).val()
    key = event.keyCode || event.charCode
    end = this.selectionEnd
    keyNumerical  = ((key >= 96 && key <= 105) || (key >= 48 && key <= 57) && !event.shiftKey)
    keyDelete     = [8, 46].includes(key)
    
    if keyNumerical || keyDelete # Only change if editing phone
      phoneNumerical = val.replace(new RegExp("\\(|\\)|-|\\s|[a-zA-Z]|#{I18n.t('constants.phone.extension')}", 'g'), '')
      phone = ""

      if phoneNumerical.length > 0
        phone += "(#{phoneNumerical.slice(0,3)}"
      if phoneNumerical.length > 3
        phone += ") #{phoneNumerical.slice(3,6)}"
      if phoneNumerical.length > 6
        phone += "-#{phoneNumerical.slice(6,10)}"
      if phoneNumerical.length > 10
        phone += " #{I18n.t('constants.phone.extension')} #{phoneNumerical.substr(10)}"

      if keyNumerical
        if end == 1 || end == 10
          end += 1
        else if end == 5
          end += 2
        else if end == 15
          end += " #{I18n.t('constants.phone.extension')} ".length
      else
        end = end

      $(this).val(phone)

      this.setSelectionRange(end, end)

      if phone.match(new RegExp("^\\(\\d{3}\\) \\d{3}-\\d{4}( #{I18n.t('constants.phone.extension')} \\d+)?$"))
        $(this).parents('.form-group').removeClass('is-invalid').addClass('is-valid')
      else
        $(this).parents('.form-group').removeClass('is-valid').addClass('is-invalid')
  )

(exports ? this).initializeSelectpickers = () ->
  $('.selectpicker').each ->
    $(this).selectpicker() if $(this).siblings('.dropdown-toggle').length == 0

(exports ? this).initializeDateTimePickers = () ->
  $('.datetimepicker.date:not(.time)').datetimepicker({ format: 'L' })
  $('.datetimepicker.time:not(.date)').datetimepicker({ format: 'LT' })
  $('.datetimepicker.date.time').datetimepicker()

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
  $('.required:not(.has-indicator)').addClass('has-indicator').append("<span class='required-indicator text-danger ml-1'>#{I18n.t('constants.required_fields.indicator')}</span>")
  $('.has-indicator:not(.required)').removeClass('has-indicator').children('.required-indicator').remove()

(exports ? this).getSRId = ->
  $("input[name='srid']").val()

(exports ? this).getSSRId = ->
  $("input[name='ssrid']").val()

(exports ? this).getProtocolId = ->
  $("input[name=protocol_id]").val()
