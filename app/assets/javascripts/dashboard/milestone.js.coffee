$ ->

  $(document).on 'dp.change', '.start-date-picker', (e) ->
    $('.start-date-setter').val(e.date)

  $(document).on 'dp.change', '.end-date-picker', (e) ->
    $('.end-date-setter').val(e.date)

  $(document).on 'dp.change', '.recruitment-start-date-picker', (e) ->
    $('.recruitment-start-date-setter').val(e.date)

  $(document).on 'dp.change', '.recruitment-end-date-picker', (e) ->
    $('.recruitment-end-date-setter').val(e.date)
