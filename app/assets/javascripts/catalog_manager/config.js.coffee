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

$ ->
  Sparc.config = {
    ready: ->
      $('.datepicker').die('change')
      $('.datepicker').live('change', ->
        submitted_field = $(this).siblings('.submitted_date')
        submitted_field.val(Sparc.config.readyMyDate($(this).val(), 'send')).change()
      )

      Sparc.config.setDatePicker("with button image")


    setDatePicker: (button_image=null) ->
      today_button_callback = (input) ->
        # the 'Today' button makes the Clear button disappear when clicked
        # since we are hacking jQuery UI anyway, we're just hiding this
        # button to prevent the issue.
        buttonPane = $(input).datepicker( "widget" ).find( ".ui-datepicker-buttonpane" )
        buttonPane.find('button.ui-datepicker-current').hide()
        buttonPane.find('button.ui-datepicker-close').on 'click', ->
            $.datepicker._clearDate(input)

      datepicker_attributes = {
        constrainInput: true
        dateFormat: "m/dd/yy"
        changeYear: true
        changeMonth: true
        showButtonPanel: true
        closeText: "Clear"
        showMonthAfterYear: true

        nextText: ""
        prevText: ""
        onChangeMonthYear: (year, month, input) ->
          setTimeout( today_button_callback, 1, [input])
        beforeShow: (input) ->
          setTimeout( today_button_callback, 1, [input])
      }
      if button_image
        datepicker_attributes.showOn = "both"
        datepicker_attributes.buttonText = "Select a Date"
        datepicker_attributes.buttonImageOnly = true
        datepicker_attributes.buttonImage = "/assets/catalog_manager/calendar_edit.png"

      for datepicker in $('.datepicker')
        if $(datepicker).attr('past_date') == 'true'
          datepicker_attributes.minDate = null
        else
          datepicker_attributes.minDate = 0
        $(datepicker).removeClass('hasDatepicker').removeAttr('id').datepicker(datepicker_attributes)


      $('.datepicker').attr("readOnly", true)

    readyMyDate: (date_string, action) ->
      try
        return "" unless date_string
        if action is 'send'
          [garbage, month, day, year] = date_string.match(/(\d)\/(\d?\d)\/(\d{4})/)
          month = "1#{month}" if date_string.length == 10
          formatted_month = if(month.length < 2) then ("0" + month) else month
          "#{year}-#{formatted_month}-#{day}"
        else
          old_format      = /(\d?\d)\/(\d?\d)\/(\d{4})/
          from_db_format = /(\d{4})-(\d\d)-(\d\d)/
          if date_string.match(old_format)
            [garbage, month, day, year] = date_string.match(old_format)
          else
            [garbage, year, month, day] = date_string.match(from_db_format)
          "#{parseFloat(month)}/#{day}/#{year}"
      catch error
        ""

    displayDatesForUser: (date_elements) ->
      for date in date_elements
        $(date).val(Sparc.config.readyMyDate($(date).val(), 'view'))

  }


