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
      datepicker_attributes = {
        constrainInput: true
        dateFormat: "m/dd/yy"
        changeYear: true
        changeMonth: true
        showButtonPanel: true
        showMonthAfterYear: true

        nextText: ""
        prevText: ""
        beforeShow: (input) ->
          # the 'Today' button makes the Clear button disappear when clicked
          # since we are hacking jQuery UI anyway, we're just hiding this
          # button to prevent the issue.
          callback = ->
            buttonPane = $(input).datepicker( "widget" ).find( ".ui-datepicker-buttonpane" )
            buttonPane.find('button.ui-datepicker-current').hide()          
            $( "<button>", {
              class: "ui-state-default ui-priority-primary ui-corner-all"
              text: "Clear"
              click: -> 
                $.datepicker._clearDate(input)
            }).appendTo(buttonPane)
          setTimeout( callback, 1)
      }
      if button_image
        datepicker_attributes.showOn = "both"
        datepicker_attributes.buttonText = "Select a Date"
        datepicker_attributes.buttonImageOnly = true
        datepicker_attributes.buttonImage = "calendar_edit.png"

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
          month_int = parseFloat(month)
          formatted_month = if(month_int < 10) then month.charAt(1) else month
          "#{formatted_month}/#{day}/#{year}"
      catch error
        ""

    displayDatesForUser: (date_elements) ->
      for date in date_elements
        $(date).val(Sparc.config.readyMyDate($(date).val(), 'view'))

  }

  #  Need to come back to this as a possible solution to the double datepickers on the date elements. -- RDN 
  # 
  # $(document).on "nested:fieldAdded", (event) ->
  #   # this field was just inserted into your form
  #   field = event.field
  #   # it's a jQuery object already! Now you can find date input
  #   dateField = field.find(".datepicker")
  # 
  #   dateField(Sparc.config.setDatePicker("with button image"))
